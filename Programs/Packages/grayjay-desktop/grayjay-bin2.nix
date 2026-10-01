{
# Core Nix/Build System
 lib
,stdenvNoCC

# Package Management/Fetching
,fetchurl

# Build Tools/Wrappers
,unzip
,makeWrapper
# ,copyDesktopItems
,autoPatchelfHook
,makeDesktopItem

# System Libraries/Core
,icu
,curl
,libz
,glib
,udev
,dbus
,expat
,openssl

# Graphics/Display
,mesa
,cairo
,libGL
,libGLU
,pango
,gtk3
,libdrm
,xorg
,libxkbcommon

# Desktop/UI
,atk
,nss
,nspr
,cups

# Audio
,alsa-lib

# Security
,libsecret

# Additional dependencies
,libgcc
,krb5

# .NET Runtime dependencies
,libuuid
,fontconfig

}:

stdenvNoCC.mkDerivation rec {
  pname = "grayjay";

  dontStrip    = true;                        # Don't strip binaries as they might be needed for the application to work
  isExecutable = true;                        # Explicitly tell it's an executable
  dontPatchELF = false;
  # autoPatchelfIgnoreMissingDeps = true;     # Automatically patch ELF files


  version = "7";

  src = fetchurl {
    url = "https://updater.grayjay.app/Apps/Grayjay.Desktop/${version}/Grayjay.Desktop-linux-x64-v${version}.zip";
    hash = "sha256-XVP6WL0BXESGv3j+UrrFCSfMIIW0d8z8J5ihXjPjzNc=";
  };

  #TODO: should be removed as it's included inside the zip folder!
  # icon = fetchurl {
  #   url = "https://grayjay.app/desktop/images/Vectors-Wrapper_1.svg";
  #   hash = "sha256-Ru7GAEgHZlrHiafO1m5iSQ8cIFjYt2qTDgL7j4bfDa0=";
  # };

  nativeBuildInputs = [
    unzip
    makeWrapper
    # copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    libz
    icu
    openssl
    libgcc
    krb5
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    gtk3
    glib
    nss
    nspr
    dbus
    atk
    cups
    libdrm
    expat
    libxkbcommon
    pango
    cairo
    udev
    alsa-lib
    mesa
    libGL
    libGLU
    libsecret
    fontconfig
    libuuid
    curl
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "grayjay";
      exec = "grayjay";
      icon = "grayjay";
      desktopName = "Grayjay";
      comment = "Follow creators, not platforms";
      categories = [ "AudioVideo" "Video" "Player" ];
      startupNotify = true;
      startupWMClass = "Grayjay";
    })
  ];

  # Nix will automatically unpack the zip file
  sourceRoot = "Grayjay.Desktop-linux-x64-v${version}";


  installPhase = ''
    # Create directory structure following XDG standards
    mkdir -p $out/bin
    mkdir -p $out/lib/grayjay
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/icons/hicolor/scalable/apps

    # Copy all application files to lib directory (following official package structure)
    cp -r . $out/lib/grayjay/

    # Copy the icon to the share directory
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp "grayjay.png" $out/share/icons/hicolor/256x256/apps/grayjay.png


    # Make the main executable and other binaries executable
    chmod +x $out/lib/grayjay/Grayjay
    chmod +x $out/lib/grayjay/FUTO.Updater.Client
    chmod +x $out/lib/grayjay/ffmpeg

    # Create symlinks for temp directories (like official package)
    # rm -f $out/lib/grayjay/Portable
    ln -s /tmp/grayjay-launch $out/lib/grayjay/launch

    # Create wrapper script with improved .NET runtime support
    makeWrapper $out/lib/grayjay/Grayjay $out/bin/grayjay \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PATH : "${lib.makeBinPath [ xorg.xprop ]}" \
      --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 0 \
      --set DOTNET_EnableDiagnostics 0 \
      --set DOTNET_ENVIRONMENT Production \
      --run "GRAYJAY_DATA_DIR=\"\''${XDG_DATA_HOME:-\$HOME/.local/share}/Grayjay\"" \
      --run "mkdir -p \"\$GRAYJAY_DATA_DIR\"" \
      --run "mkdir -p \"\''${XDG_CONFIG_HOME:-\$HOME/.config}/Grayjay\"" \
      --run "mkdir -p \"\''${XDG_CACHE_HOME:-\$HOME/.cache}/Grayjay\"" \
      --run "mkdir -p /tmp/grayjay-launch" \
      --run "cd \"\$GRAYJAY_DATA_DIR\"" \
      --run "if [ ! -f ./Grayjay ] || [ $out/lib/grayjay/Grayjay -nt ./Grayjay ]; then cp -rf $out/lib/grayjay/* .; chmod +x ./Grayjay ./FUTO.Updater.Client ./ffmpeg 2>/dev/null || true; fi" \
      --run "exec ./Grayjay" \
      --argv0 "Grayjay"

    runHook postInstall
  '';

    # Install SVG icon
    # cp grayjay.png $out/share/pixmaps/grayjay.png
    # cp ${icon} $out/share/icons/hicolor/scalable/apps/grayjay.svg

  meta = with lib; {
    maintainers      = [ offline];
    platforms        = [ "x86_64-linux" ];
    license          = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram      = "grayjay";
    homepage         = "https://grayjay.app";
    description      = "Follow creators, not platforms";
    longDescription  = "Grayjay is a video platform aggregator that allows you to follow creators across multiple platforms without being tied to any single one.";
  };


}