# ==============================================================================
# Hardware Overrides & Machine-Specific Configuration
# ==============================================================================
#
# PURPOSE:
# This file contains hardware-specific tweaks that should NOT go into the
# auto-generated 'hardware-configuration.nix'. This keeps the main hardware
# file reproducible and safe to regenerate via 'nixos-generate-config'.
#
# WHAT GOES HERE:
# - Blacklisted/forced kernel modules
# - Hardware-specific services (Bluetooth, SMART, fstrim)
# ==============================================================================

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    # Bootloader
    loader ={
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    };

    kernelPackages =
    #   pkgs.linuxKernel.packages.linux_6_18;
    #   pkgs.linuxPackages_latest;                    # the latest kernel aliased in the nixpkgs

    #! DIY approach - this takes indeed so much time (I am praying for kernel maintainers since I tried this lol)
    #  pkgs.linuxPackagesFor (pkgs.linux_6_12.override {
    #   argsOverride = rec {
    #     version = "6.12.8";
    #     modDirVersion = "6.12.8";
    #       src = pkgs.fetchurl {
    #                   url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
    #                   sha256 = "sha256-IpHaBlygS3Fcie5QNirsPwIadBS8lj8bVnNmgsgSKXk=";
    #       };
    #     };
    #   }
    # );

    # Why make an if condition here you may ask, here is my explination to whover reading this in the future
    # in NixOS 25.11 release in 2026 there was a major vulnerability called Copy Fail
    # it was so big it had it's very own website: https://copy.fail/
    # there was a discussion on : https://discourse.nixos.org/t/is-nixos-affected-by-copy-fail-edit-yes-it-is/77317/11
    # that suggested this approach as a temporary fix for the people who were relying on the default kernel of that release of NixOS (25.11)
    #
    #? History
    #  6.18.8: CVE-2026-31431 / Copy Fail | metigated by updating to 6.18.22 or later
     lib.mkIf (lib.versionOlder pkgs.linux.version "7.0.0") (
          lib.mkDefault pkgs.linuxKernel.packages.linux_7_0);

    extraModulePackages = with config.boot.kernelPackages; [
      # rtl88xxau-aircrack    # see https://discourse.nixos.org/t/solved-how-to-correctly-add-kernel-module/24974/2
    ];

    # Configure initial ramdisk modules
    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "ahci" "xhci_pci"
        "usbhid" "usb_storage"
      ];
      kernelModules = [
           "asus_wmi"
       ];
    };

    # Configure kernel modules
    kernelModules = [
      "amd_pstate" "kvm-amd"
      "asus_wmi"
      "thunderbolt" "usb4"

      "tun"

      "asus-armoury"

      "typec"              # USB-C subsystem
      "typec_mux"          # Mux control for alternate modes
      "typec_dp"           # DisplayPort over USB-C
      "usb_typec"          # General USB-C device handling
    ];

    # Blacklist specific kernel modules
    blacklistedKernelModules = [
    #! Camera drivers
    "mc"
    "uvcvideo"
    "videodev"
    "videobuf2_v4l2"
    "videobuf2_common"
    "videobuf2_vmalloc"

    #! AMDGPU drivers
    "amdgpu" "radeon"
    ];

    #> Kernel parameters configuration
    kernelParams = [
      "acpi_backlight=active" "acpi_osi=Linux"

      "usbcore.autosuspend=-1"

      # "libata.force=noncq"  # Disable NCQ power management
      "ahci.mobile_lpm_policy=0"  # Disable AHCI Link Power Management

      # CPU optimizations
      "amd_iommu=on"
      "mitigations=on"
      "amd_pstate=guided"      # Enable AMD P-State driver
      # "processor.max_cstate=7"  # Limit C-states for better response time

      # Remove
      "nowatchdog"
      "intel_pstate=disable"

      # "preempt=full"           # Better for desktop/low-latency
      # "mce=ignore_ce"          # Ignore non-fatal Correctable Errors (reduces log noise)
      "scsi_mod.use_blk_mq=1"    # Use multi-queue for faster I/O

      # Memory security parameters
      "slab_nomerge"            # Disables merging of slabs of similar sizes
      "vsyscall=none"           # Disables legacy system call interface
      "page_alloc.shuffle=1"    # Helps detect memory issues earlier + Major security gain

      #! these do have a major performance penalty, do not enable them on a daily driver
      # "slub_debug=FZP"          # Enables sanity checks (F), redzoning (Z) and poisoning (P).
      # "init_on_free=1"          # Fill freed pages and heap objects with zeroes
      # "init_on_alloc=1"         # to initialize memory on allocation (complements init_on_free=1).

      # New memory management parameters
      "hugepagesz=2M"                # Enable 2MB huge pages
      "hugepages=2048"               # Reserve 4GB for huge pages (2048 * 2MB)
      "default_hugepagesz=2M"        # Set default huge page size
      "transparent_hugepage=madvise" # Enable transparent huge pages

      "pti=on"                      # Page Table Isolation for security
      # "page_poison=1"             # Poison freed memory pages (As it conflicts with init_on_free)
      "randomize_kstack_offset=on"  # Enhanced kernel stack ASLR

    ];

    kernel.sysctl = {
    #! Swap related
    "vm.swappiness" = 10;  # Change this value as needed (0-100) 0 makes kernel avoid swap as much as possible

    #! Memory management
    "vm.dirty_ratio" = 10;                  # Full writeback at 10%
    "vm.page-cluster" = 3;                  # Default page clustering (test with 0 if needed)
    "vm.min_free_kbytes" = 65536;           # Reserve 64MB of free memory (adjust as needed)
    "vm.dirty_background_ratio" = 5;        # Background writeback at 5%
    "vm.compaction_proactiveness" = 0;      # Default memory compaction (change to 1 if fragmentation issues arise)

    # Memory security
    "vm.mmap_rnd_bits" = 32;                # Increase ASLR entropy
    "kernel.kptr_restrict" = 2;             # Hide kernel pointers
    "kernel.dmesg_restrict" = 1;            # Restrict dmesg access
    "vm.mmap_rnd_compat_bits" = 16;         # Compatible ASLR entropy

    # DDR5 and NUMA settings
    "vm.zone_reclaim_mode" = 0;             # Disable zone reclaim for NUMA
    "kernel.numa_balancing" = 0;            # Disable automatic NUMA balancing
    };
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.smartd = {
    enable = true;
    autodetect = true;
    notifications = {
      mail.enable = false;
      # mail.recipient = "your-email@example.com";  # Replace with your email
    };
    defaults = {
      # Monitor all attributes, auto-enable monitoring, check every 30 minutes
      monitored = "-a -o on -S on -s (S/../.././02|L/../../7/03)";
    };
    devices = [
      {
        device = "/dev/nvme0n1";
        options = "-d nvme";
      }
    ];
  };

  zramSwap = {
    enable = config.hardware.isDellG15;
    algorithm = "zstd";
    priority = 10;
    memoryPercent = 100;
  };

  services.acpid.enable= true;

  hardware.bluetooth = {
    enable = true;               # enables support for Bluetooth
    powerOnBoot = false;         # powers up the default Bluetooth controller on boot
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
  };

}
