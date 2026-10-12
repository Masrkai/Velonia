{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
      ];

      cores = 10;
      max-jobs = 2;
      sandbox = true;
      builders-use-substitutes = true;
      system-features = ["big-parallel" "kvm"];

      # WARN: DO NOT ADD A USER TO THIS OTHER THAN ROOT
      # WHICH IS IN FACT THE DEFAULT SO THERE IS NO NEED 
      # TO EVEN DECLARE IT SPECIALLY DON'T ENABLE OR ADD 
      # A NORMAL USER UNLESS YOU ABSOLUTLY KNOW WHAT YOU
      # ARE DOING

      # BUG When "root" is specified the output of a command like:
      # nix config show trusted-users
      # becomes: "root root"
      # which is trivial at first but idk the extent of the bug issues
      # so just be aware to not add "root"
      # trusted-users = [
      #   "root"
      # ];

      keep-derivations = false;
      keep-outputs = false;
    };
  };

  nixpkgs = {
    overlays = [
      # FROM: https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3694376547
      # WARN: READ THE COMMENT AFTER THE ONE THAT IS LINKED
      # (final: prev: {
      #   kdePackages = prev.kdePackages.overrideScope (
      #     kdeFinal: kdePrev: {
      #       # https://old.reddit.com/r/NixOS/comments/1pdtc3v/kde_plasma_is_slow_compared_to_any_other_distro/
      #       # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
      #       plasma-workspace = let
      #         # the package we want to override
      #         basePkg = kdePrev.plasma-workspace;
      #         # a helper package that merges all the XDG_DATA_DIRS into a single directory
      #         xdgdataPkg = final.stdenv.mkDerivation {
      #           name = "${basePkg.name}-xdgdata";
      #           buildInputs = [basePkg];
      #           dontUnpack = true;
      #           dontFixup = true;
      #           dontWrapQtApps = true;
      #           installPhase = ''
      #             mkdir -p $out/share
      #             ( IFS=:
      #               for DIR in $XDG_DATA_DIRS; do
      #                 if [[ -d "$DIR" ]]; then
      #                   ${prev.lib.getExe prev.lndir} -silent "$DIR" $out
      #                 fi
      #               done
      #             )
      #           '';
      #         };
      #         # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
      #         # script and instead inject the path of the above helper package
      #         derivedPkg = basePkg.overrideAttrs {
      #           preFixup = ''
      #             for index in "''${!qtWrapperArgs[@]}"; do
      #               if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
      #                 unset -v "qtWrapperArgs[$((index+0))]"
      #                 unset -v "qtWrapperArgs[$((index+1))]"
      #                 unset -v "qtWrapperArgs[$((index+2))]"
      #                 unset -v "qtWrapperArgs[$((index+3))]"
      #               fi
      #             done
      #             qtWrapperArgs=("''${qtWrapperArgs[@]}")
      #             qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
      #             qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
      #           '';
      #         };
      #       in
      #         derivedPkg;
      #     }
      #   );
      # })
      #
      (final: prev: let
        unstable = import <unstable> {
          config = config.nixpkgs.config;
        };
      in {
        # Unstable package pins — single eval, submodules use pkgs.*
        grayjay = unstable.grayjay;
        ani-cli = unstable.ani-cli;
        qdiskinfo = unstable.qdiskinfo;
        opencode = unstable.opencode;
        pi-coding-agent = unstable.pi-coding-agent;
        pince = unstable.pince;
        metasploit = unstable.metasploit;
        nixoscope = unstable.nixoscope;
        signal-desktop = unstable.signal-desktop;
        heroic-unwrapped = unstable.heroic-unwrapped;
        yt-dlp = final.callPackage ./Programs/Packages/yt-dlp.nix {};

        filterOutX11 = prev.lib.filterAttrs (name: pkg:
          !(final.lib.strings.contains "libX11" (toString pkg)
            || final.lib.strings.contains "xset" (toString pkg)
            || final.lib.strings.contains "x11-utils" (toString pkg)))
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
          withWhisper = false;
          withSvtav1 = true;
          withAom = true;
          withTensorflow = false;

          withMetal = false;
          withMfx = false;
        };

        ffmpeg-full = prev.ffmpeg-full.override {
          withWhisper = false;
          withSvtav1 = true;
          withAom = true;
          withTensorflow = false;

          withMetal = false;
          withMfx = false;
        };

        pythonPackagesExtensions = [
          (py-final: py-prev: {
            trl = py-final.callPackage ./Programs/python-libs/trl.nix {};
            tyro = py-final.callPackage ./Programs/python-libs/tyro.nix {};
            datasets = py-final.callPackage ./Programs/python-libs/datasets.nix {};
            smolagents = py-final.callPackage ./Programs/python-libs/smolagents.nix {};
            #           onnxruntime = py-final.callPackage ./Programs/python-libs/onnxruntime.nix{};

            cut-cross-entropy = py-final.callPackage ./Programs/python-libs/cut-cross-entropy.nix {};

            vllm = py-final.callPackage ./Programs/python-libs/vllm.nix {};
            keras = py-final.callPackage ./Programs/python-libs/keras.nix {};
            flash-attn = py-final.callPackage ./Programs/python-libs/flash-attn.nix {};

            unsloth = py-final.callPackage ./Programs/python-libs/unsloth/unsloth.nix {};
            unsloth-zoo = py-final.callPackage ./Programs/python-libs/unsloth/unsloth-zoo.nix {};

            #           fairseq2 = py-final.callPackage ./Programs/python-libs/fairseq2.nix{ };

            #            jax = py-final.callPackage ./Programs/python-libs/jax.nix{ };
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
