{
  config,
  pkgs,
  lib,
  ...
}: let
  hasNvidia = config.hardware.isDellG15 || config.hardware.isAsusTuf;
in {
  config = lib.mkMerge [
    #> Base graphics: every device
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      environment.systemPackages = with pkgs; [
        #? Diagnostics
        clinfo # OpenCL information
        (lib.lowPrio mesa-demos) # GLX diagnostics (renamed from glxinfo)
        libva-utils # VA-API diagnostics
        vulkan-tools # Vulkan utilities
      ];
    }

    #> NVIDIA: only Dell G15 / Asus TUF
    (lib.mkIf hasNvidia {
      #> Load nvidia driver for Xorg and Wayland
      services.xserver = {
        videoDrivers = ["nvidia"];
        screenSection = ''
          option "TearFree" "true"
          option "VariableRefresh" "true"
        '';
      };

      boot = {
        initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm"];
        kernelModules = ["nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm"];

        kernelParams = [
          "pci=realloc=on"

          "NVreg_PreserveVideoMemoryAllocations=1"
          "nvidia.NVreg_TemporaryFilePath=/var/tmp"

          "nvidia.NVreg_UsePageAttributeTable=1"

          "nvidia.NVreg_EnableGpuFirmware=0"
        ];

        # Blacklist specific kernel modules
        blacklistedKernelModules = [
          "nouveau" # Blacklist open-source NVIDIA driver
          "nvidiafb"
          "nvidia_wmi_ec_backlight"
        ];
      };

      #! OpenCL ICD loader (only needed alongside the NVIDIA stack)
      hardware.graphics.extraPackages = with pkgs; [
        # libvdpau-va-gl
        ocl-icd
      ];

      #? History lesson
      # There were two separate migration hops that happened for the cuda cache
      #
      # 1st The nixpkgs-cuda-ci project (which powered cuda-maintainers.cachix.org) was discontinued
      # in favour of the CUDA-enabled nixpkgs release built on the "community Hydra"
      # and cached at nix-community.cachix.org .
      #
      # 2nd The cache moved from cuda-maintainers.cachix.org to
      # cache.nixos-cuda.org in November 2025, So (nix-community.cachix.org) was a transitional step.
      #
      # Conclusion is, don't use (cuda-maintainers.cachix.org) as it's discontinued
      nix.settings = {
        substituters = [
          # "https://cuda-maintainers.cachix.org"
          "https://nix-community.cachix.org"
          "https://cache.nixos-cuda.org"
        ];
        trusted-public-keys = [
          # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];
      };

      nixpkgs.config = {
        cudaSupport = true;
        cudaForwardCompat = false;
      };

      hardware.nvidia = {
        open = true;
        nvidiaSettings = true;
        videoAcceleration = true;
        modesetting.enable = true;

        dynamicBoost.enable = false;
        powerManagement.enable = false; # because there is no other GPU to handle desktop

        forceFullCompositionPipeline = false; # Better screen tearing prevention
        package =
          config.boot.kernelPackages.nvidiaPackages.legacy_580
          #! Manually pin pointed Nvidia Driver
          # config.boot.kernelPackages.nvidiaPackages.mkDriver {
          #   version = "570.86.16";
          #   sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
          #   openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
          #   settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
          #   usePersistenced = false;
          # }
          ;
      };

      environment = {
        systemPackages = with pkgs; [
          #? CUDA
          #? videoAcceleration
          libva-vdpau-driver
          nv-codec-headers-12

          #> Un-needed (Arguably but this is a single GPU platform)

          # cudatoolkit is officially deprecated and discouraged
          # in modern nixpkgs this is just a compatibility shim
          # cudatoolkit

          # the CUDA compiler. Only needed if you're actually
          # compiling CUDA code on this machine. If you're just
          # running pre-built apps (PyTorch, Blender, etc.)
          # you don't need it globally
          # cudaPackages.cuda_nvcc

          # CUDA C++ Core Libraries (headers/abstractions used
          # when writing CUDA kernels). Pure build-time dev dependency.
          # cudaPackages.cuda_cccl

          # the CUDA runtime. This sounds essential but NixOS actually
          # injects this through the driver infrastructure
          # at /run/opengl-driver. Apps that need it get it through their
          # own closure, not from your system packages.
          # cudaPackages.cuda_cudart

          # NVIDIA's multi-GPU collective communications library.
          # Only relevant if you're doing distributed ML training
          # across multiple GPUs. On a single-GPU desktop it does nothing.
          # cudaPackages.nccl

          # NVIDIA's deep learning primitives library (convolutions, activations, etc.).
          # Only needed if you're training or running neural networks with frameworks
          # like PyTorch/TensorFlow that explicitly link against it. Those frameworks
          # bring their own cudnn in their closure anyway when installed with CUDA support,
          # so having it globally is redundant unless you're doing custom development against it directly.
          # cudaPackages.cudnn

          # NVIDIA Performance Primitives, basically
          # CUDA-accelerated image/signal processing routines.
          # Very niche. Only needed if you're doing direct
          # NPP API calls in your own code.
          # No typical end-user app needs this from system packages.
          # cudaPackages.libnpp
        ];

        #! DO NOT ENABLE THIS, THIS IS A BAD PRACTICE
        # Wayland bringed explicit sync and this should
        # have been the way it worked from the start
        # I DO NOT ENCOURAGE NOR RECOMMEND DISABLING IT
        # variables = {
        #   __NV_DISABLE_EXPLICIT_SYNC="1";
        # };
      };
    })
  ];
}
