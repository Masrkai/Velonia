{
  lib,
  fetchurl,
  stdenvNoCC,
  buildFHSEnv,
  makeDesktopItem,
  writeShellScript,


  icu,
  udev,
  libz,
  unzip,
  openssl,


  libdrm,
  alsa-lib,
  nss,
  atk,
  gtk3,
  xorg,
  glib,
  nspr,
  dbus,
  # cups,
  mesa,
  expat,
  pango,
  cairo,
  libGL,
  libsecret,
  libnotify,
  libxkbcommon,
}:
let
  version = "7";
  # Fetch the SVG icon
  icon = fetchurl {
    url = "https://grayjay.app/desktop/images/Vectors-Wrapper_1.svg";
    name = "grayjay-icon.svg";
    sha256 = "sha256-Ru7GAEgHZlrHiafO1m5iSQ8cIFjYt2qTDgL7j4bfDa0=";
  };
  grayjay-app = stdenvNoCC.mkDerivation {
    pname = "grayjay-app";
    inherit version;
    src = fetchurl {
      url = "https://updater.grayjay.app/Apps/Grayjay.Desktop/${version}/Grayjay.Desktop-linux-x64-v${version}.zip";
      hash = "sha256-XVP6WL0BXESGv3j+UrrFCSfMIIW0d8z8J5ihXjPjzNc=";
    };

    nativeBuildInputs = [
      unzip
    ];

    sourceRoot = ".";
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      # Create required directories
      mkdir -p $out/bin $out/opt/grayjay $out/share/icons/hicolor/scalable/apps

      # Extract app files
      unzip -d $out/tmp $src
      mv $out/tmp/Grayjay.Desktop-linux-x64-v${version}/* $out/opt/grayjay/
      rm -rf $out/tmp

      # Install SVG icon
      install -Dm444 ${icon} $out/share/icons/hicolor/scalable/apps/grayjay.svg

      # Remove portable mode file if it exists
      rm -f $out/opt/grayjay/Portable
    '';

    meta = with lib; {
      homepage = "https://grayjay.app/desktop/";
      description = "Grayjay Desktop - follow creators, not platforms (privacy- and freedom-respecting client for YouTube, Rumble, Twitch, Spotify etc)";
      license = licenses.unfree; # Source First License 1.1
      platforms = platforms.linux;
    };
  };

  # Create the desktop file
  desktopItem = makeDesktopItem {
    name        = "grayjay";
    desktopName = "Grayjay";
    exec        = "grayjay";
    icon        = "grayjay";
    categories  = [ "Video" ];
    comment     = "Privacy-respecting client for YouTube, Rumble, Twitch, Spotify etc";
  };

in
buildFHSEnv {
  name = "grayjay";
  targetPkgs = pkgs: [
    grayjay-app
    # Base dependencies from original derivation
    libz
    icu
    openssl
    # X11 dependencies
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb

    # GTK and UI dependencies
    gtk3
    glib
    nss
    nspr
    dbus
    atk
    # cups
    libdrm
    expat
    libxkbcommon
    pango
    cairo
    udev
    alsa-lib
    mesa
    libGL
    libsecret
    libnotify
  ];
  multiPkgs = pkgs: [ libGL ];

  # Create a launcher script that safely sets up and runs Grayjay
  runScript = writeShellScript "grayjay-script" ''
    # Grayjay expects to be in ~/Grayjay according to the logs
    APP_DIR="$HOME/Grayjay"

    # Create the directory if it doesn't exist
    mkdir -p "$APP_DIR"

    # Check if application files need to be copied (first run or update)
    if [ ! -f "$APP_DIR/Grayjay" ] || [ "${grayjay-app}/opt/grayjay/Grayjay" -nt "$APP_DIR/Grayjay" ]; then
      echo "Installing/updating Grayjay to $APP_DIR"
      # Create backup of user data if it exists
      if [ -d "$APP_DIR/Data" ]; then
        echo "Creating backup of user data..."
        mkdir -p "$APP_DIR/backup"
        cp -r "$APP_DIR/Data" "$APP_DIR/backup/"
      fi

      # Copy the application files, preserving permissions
      cp -a ${grayjay-app}/opt/grayjay/* "$APP_DIR/"

      # Make sure everything is writable by the user
      chmod -R u+w "$APP_DIR"

      # Restore user data if it was backed up
      if [ -d "$APP_DIR/backup/Data" ]; then
        echo "Restoring user data..."
        cp -r "$APP_DIR/backup/Data" "$APP_DIR/"
        # Keep just the most recent backup
        rm -rf "$APP_DIR/backup"
      fi

      # Create a Portable file to tell Grayjay to use the current directory for data
      touch "$APP_DIR/Portable"
    fi

    # Change to application directory and run
    cd "$APP_DIR"
    exec ./Grayjay "$@"
  '';

  # Key fix: Add extraInstallCommands to copy the desktop file and icon
  extraInstallCommands = ''
    # Create desktop file directory if it doesn't exist
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps

    # Copy the desktop file to the appropriate location
    cp ${desktopItem}/share/applications/* $out/share/applications/

    # Copy the icon from the inner derivation
    cp ${grayjay-app}/share/icons/hicolor/scalable/apps/grayjay.svg $out/share/icons/hicolor/scalable/apps/
  '';

  meta = with lib; {
    homepage = "https://grayjay.app/desktop/";
    description = "Grayjay Desktop - follow creators, not platforms (privacy- and freedom-respecting client for YouTube, Rumble, Twitch, Spotify etc)";
    license = licenses.unfree; # Source First License 1.1
    platforms = platforms.linux;
    mainProgram = "grayjay";
  };
}