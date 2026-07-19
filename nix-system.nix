{ config, lib, pkgs, modulesPath, ... }:

let
  secrets = import ./Sec/secrets.nix;
in
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
      ];

      cores = 12;
      max-jobs = 4;
      sandbox = true;
      builders-use-substitutes = true;
      system-features = [ "big-parallel" "kvm" ];

      trusted-users = [
        "root"
        "@wheel"
        config.identity.username
      ];

      keep-derivations = false;
      keep-outputs = false;
    };
  };

  nixpkgs = {
    overlays = [
      (final: prev: let
        unstable = import <unstable> {
          config = config.nixpkgs.config;
        };
      in {
        # Unstable package pins — single eval, submodules use pkgs.*
        grayjay       = unstable.grayjay;
        ani-cli       = unstable.ani-cli;
        qdiskinfo     = unstable.qdiskinfo;
        ollama-cuda   = unstable.ollama-cuda;
        opencode      = unstable.opencode;
        pi-coding-agent = unstable.pi-coding-agent;
        pince         = unstable.pince;
        metasploit    = unstable.metasploit;
        nixoscope     = unstable.nixoscope;

        filterOutX11 = prev.lib.filterAttrs (name: pkg:
          !(final.lib.strings.contains "libX11" (toString pkg) ||
            final.lib.strings.contains "xset" (toString pkg) ||
            final.lib.strings.contains "x11-utils" (toString pkg)))
          prev;

        jackett = prev.jackett.overrideAttrs (oldAttrs: {
          doCheck = false;
        });

        wine = prev.wineWowPackages.stableFull.override {
          x11Support = false;
          cupsSupport = false;
          waylandSupport = true;
        };

        ffmpeg = prev.ffmpeg.override {
          withWhisper    = false;
          withSvtav1     = true;
          withAom        = true;
          withTensorflow = false;

          withMetal = false;
          withMfx = false;
        };

        ffmpeg-full = prev.ffmpeg-full.override {
          withWhisper    = false;
          withSvtav1     = true;
          withAom        = true;
          withTensorflow = false;

          withMetal = false;
          withMfx = false;
        };

        pythonPackagesExtensions = [
          (py-final: py-prev: {
            trl = py-final.callPackage ./Programs/python-libs/trl.nix{ };
            tyro = py-final.callPackage ./Programs/python-libs/tyro.nix{ };
            datasets = py-final.callPackage ./Programs/python-libs/datasets.nix{ };
            smolagents = py-final.callPackage ./Programs/python-libs/smolagents.nix{};
            onnxruntime = py-final.callPackage ./Programs/python-libs/onnxruntime.nix{};

            cut-cross-entropy = py-final.callPackage ./Programs/python-libs/cut-cross-entropy.nix{ };

            vllm = py-final.callPackage ./Programs/python-libs/vllm.nix{ };
            keras = py-final.callPackage ./Programs/python-libs/keras.nix{ };
            flash-attn = py-final.callPackage ./Programs/python-libs/flash-attn.nix{ };

            unsloth = py-final.callPackage ./Programs/python-libs/unsloth/unsloth.nix{ };
            unsloth-zoo = py-final.callPackage ./Programs/python-libs/unsloth/unsloth-zoo.nix{ };

            fairseq2 = py-final.callPackage ./Programs/python-libs/fairseq2.nix{ };

            jax = py-final.callPackage ./Programs/python-libs/jax.nix{ };
            jaxlib = py-prev.jaxlib-bin;

            torch = py-prev.torch-bin;
            torchaudio = py-final.torchaudio-bin;
            torchvision = py-final.torchvision-bin;
          })
        ];
      })
    ];

    config = {
      allowUnfree = true;
      allowBroken = false;

      permittedInsecurePackages = [
        "ciscoPacketTracer8-8.2.2"
        "minio-2025-10-15T17-29-55Z"
      ];
    };
  };
}
