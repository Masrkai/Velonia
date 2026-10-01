{ lib
, stdenv
, fetchurl
, buildFHSEnv
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, writeShellScript
, unzip
, autoPatchelfHook
, wrapGAppsHook3
, libz
, icu
, openssl
, xorg
, gtk3
, glib
, nss
, nspr
, dbus
, atk
, cups
, libdrm
, expat
, libxkbcommon
, pango
, cairo
, udev
, alsa-lib
, mesa
, libGL
, libsecret
, libgcc
, krb5
}:

let
  version = "7";

  src = fetchurl {
    url = "https://updater.grayjay.app/Apps/Grayjay.Desktop/${version}/Grayjay.Desktop-linux-x64-v${version}.zip";
    hash = "sha256-XVP6WL0BXESGv3j+UrrFCSfMIIW0d8z8J5ihXjPjzNc=";
  };

  icon = fetchurl {
    url = "https://grayjay.app/desktop/images/Vectors-Wrapper_1.svg";
    hash = "sha256-Ru7GAEgHZlrHiafO1m5iSQ8cIFjYt2qTDgL7j4bfDa0=";
  };

in stdenv.mkDerivation rec {
  pname = "grayjay";
  inherit version src;

  nativeBuildInputs = [
    unzip
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    libgcc
    xorg.libX11
    gtk3
    glib
    alsa-lib
    mesa
    nspr
    nss
    icu
    krb5
  ];

  # Don't let wrapGAppsHook3 wrap automatically - we'll do it manually
  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "grayjay";
      exec = "grayjay";
      icon = "grayjay";
      desktopName = "Grayjay Desktop";
      comment = "Follow creators, not platforms";
      categories = [ "AudioVideo" "Video" "Player" "Network" ];
      startupNotify = true;
      startupWMClass = "Grayjay";
    })
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip -q $src
    cd Grayjay.Desktop-linux-x64-v${version}
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/bin
    mkdir -p $out/lib/grayjay
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/icons/hicolor/scalable/apps

    # Copy all application files to lib directory (like official package)
    cp -r . $out/lib/grayjay/

    # Install icons
    cp grayjay.png $out/share/pixmaps/grayjay.png
    cp ${icon} $out/share/icons/hicolor/scalable/apps/grayjay.svg

    # Set proper permissions (based on official package)
    chmod +x $out/lib/grayjay/Grayjay
    chmod +x $out/lib/grayjay/FUTO.Updater.Client
    chmod +x $out/lib/grayjay/ffmpeg
    find $out/lib/grayjay/cef -name "*.so" -exec chmod +x {} \;
    find $out/lib/grayjay -name "*.so" -exec chmod +x {} \;

    # Remove Portable file (like official package does)
    rm -f $out/lib/grayjay/Portable

    # Create temp launch directories (like official package)
    mkdir -p $out/lib/grayjay/tmp
    ln -s /tmp/grayjay-launch $out/lib/grayjay/launch || true
    ln -s /tmp/grayjay-cef-launch $out/lib/grayjay/cef/launch || true

    runHook postInstall
  '';



    postFixup = ''
      # Create FHS wrapper for the application
      cat > $out/bin/grayjay << 'EOF'
    #!/bin/sh

    # Create XDG directories
    mkdir -p "''${XDG_DATA_HOME:-$HOME/.local/share}/grayjay"
    mkdir -p "''${XDG_CONFIG_HOME:-$HOME/.config}/grayjay"
    mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/grayjay"

    # Create temp directories for CEF
    mkdir -p /tmp/grayjay-launch
    mkdir -p /tmp/grayjay-cef-launch

    # Set XDG environment variables
    export GRAYJAY_DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/grayjay"
    export GRAYJAY_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/grayjay"
    export GRAYJAY_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/grayjay"

    # Run in FHS environment
    exec ${buildFHSEnv {
      name = "grayjay-fhs";
      targetPkgs = pkgs: with pkgs; [
        # Core dependencies
        libz icu openssl libgcc krb5

        # X11 and graphics
        xorg.libX11 xorg.libXcomposite xorg.libXdamage
        xorg.libXext xorg.libXfixes xorg.libXrandr xorg.libxcb
        libGL mesa

        # GTK and desktop integration
        gtk3 glib dbus atk pango cairo

        # System libraries
        nss nspr cups libdrm expat
        udev alsa-lib libsecret

        # CEF dependencies (important for Chromium Embedded Framework)
        at-spi2-atk at-spi2-core
      ];
      runScript = writeShellScript "grayjay-script" ''
        mkdir -p ~/Grayjay
        cp -r '${placeholder "out"}/lib/grayjay/'* ~/Grayjay/
        cd ~/Grayjay
        exec ./Grayjay "$@"
      '';
    }}/bin/grayjay-fhs "$@"
    EOF

      chmod +x $out/bin/grayjay
    '';

  # Runtime dependencies (similar to official package)
  runtimeDeps = [
    libz icu openssl libgcc krb5
    xorg.libX11 xorg.libXcomposite xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXrandr xorg.libxcb
    gtk3 glib nss nspr dbus atk cups libdrm expat
    libxkbcommon pango cairo udev alsa-lib mesa libGL libsecret
  ];

  # Don't strip binaries as they might be needed for CEF
  dontStrip = true;

  # Ignore missing dependencies for proprietary binaries
  autoPatchelfIgnoreMissingDeps = true;

  meta = with lib; {
    description = "Follow creators, not platforms";
    longDescription = ''
      Grayjay is a video platform aggregator that allows you to follow creators
      across multiple platforms without being tied to any single one.
      This package uses the pre-built binary distribution.
    '';
    homepage = "https://grayjay.app";
    license = licenses.unfree; # Adjust based on actual license
    maintainers = [ ]; # Add your maintainer info here
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "grayjay";
  };

  # Passthru for easy version updates
  passthru.updateScript = lib.writeShellScript "update-grayjay" ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Manual update required. Check https://updater.grayjay.app/Apps/Grayjay.Desktop/ for new versions"
    echo "Current version: ${version}"
    echo "Update the version and hash in the nix file"
  '';
}