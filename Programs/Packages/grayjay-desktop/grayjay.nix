{
  stdenv,
  lib,
  fetchurl,
  buildFHSEnv,
  writeShellScript,
  makeDesktopItem,
  copyDesktopItems,
  unzip,
  libz,
  icu,
  openssl,
  xorg,
  gtk3,
  glib,
  nss,
  nspr,
  dbus,
  atk,
  cups,
  libdrm,
  expat,
  libxkbcommon,
  pango,
  cairo,
  udev,
  alsa-lib,
  mesa,
  libGL,
  libsecret,
  libnotify,
}:
let
  version = "7";
  # Fetch the SVG icon
  icon = fetchurl {
    url = "https://grayjay.app/desktop/images/Vectors-Wrapper_1.svg";
    name = "grayjay-icon.svg";
    sha256 = "sha256-Ru7GAEgHZlrHiafO1m5iSQ8cIFjYt2qTDgL7j4bfDa0=";
  };
  grayjay-app = stdenv.mkDerivation {
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
      
      # Add a version file to track installed version
      echo "${version}" > $out/opt/grayjay/nix-pkg-version
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
    name = "grayjay";
    desktopName = "Grayjay";
    exec = "grayjay";
    icon = "grayjay";
    comment = "Privacy-respecting client for YouTube, Rumble, Twitch, Spotify etc";
    categories = [ "Video" ];
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
    
    # Define the list of user data directories and files to preserve during updates
    USER_DATA_DIRS=(
      "downloaded"
      "downloads"
      "downloads_ongoing"
      "downloads_playlists"
      "imageCache"
      "pinnedDevices"
      "playlists"
      "plugin_scripts"
      "plugins"
      "previousSearches_0"
      "subscription_groups"
      "subscriptions"
      "subscriptions_others"
      "watchLater"
    )
    
    USER_DATA_FILES=(
      "database.db"
      "enabledClients"
      "id"
      "settings.json"
      "sub_exchange_key"
      "syncKeyPair"
      "watchLaterRemovals"
    )
    
    # Check if application needs to be updated by comparing version
    INSTALLED_VERSION_FILE="$APP_DIR/nix-pkg-version"
    PACKAGE_VERSION="${version}"
    
    # Update is needed if:
    # 1. Grayjay executable doesn't exist, or
    # 2. Version file doesn't exist, or
    # 3. Version in file doesn't match package version
    UPDATE_NEEDED=0
    if [ ! -f "$APP_DIR/Grayjay" ] || \
       [ ! -f "$INSTALLED_VERSION_FILE" ] || \
       [ "$(cat "$INSTALLED_VERSION_FILE" 2>/dev/null)" != "$PACKAGE_VERSION" ]; then
      UPDATE_NEEDED=1
    fi
    
    if [ "$UPDATE_NEEDED" -eq 1 ]; then
      echo "Installing/updating Grayjay to $APP_DIR (Version: $PACKAGE_VERSION)"
      
      # Create temporary directory for user data backup
      BACKUP_DIR="$APP_DIR/.nix-backup-$(date +%s)"
      mkdir -p "$BACKUP_DIR"
      
      # Backup user data directories
      for dir in "''${USER_DATA_DIRS[@]}"; do
        if [ -d "$APP_DIR/$dir" ]; then
          echo "Backing up $dir..."
          cp -a "$APP_DIR/$dir" "$BACKUP_DIR/"
        fi
      done
      
      # Backup user data files
      for file in "''${USER_DATA_FILES[@]}"; do
        if [ -f "$APP_DIR/$file" ]; then
          echo "Backing up $file..."
          cp -a "$APP_DIR/$file" "$BACKUP_DIR/"
        fi
      done
      
      # Copy all application files from the package
      echo "Copying application files..."
      cp -a ${grayjay-app}/opt/grayjay/* "$APP_DIR/"
      
      # Make sure everything is writable by the user
      chmod -R u+w "$APP_DIR"
      
      # Restore user data directories
      for dir in "''${USER_DATA_DIRS[@]}"; do
        if [ -d "$BACKUP_DIR/$dir" ]; then
          echo "Restoring $dir..."
          rm -rf "$APP_DIR/$dir" 2>/dev/null
          cp -a "$BACKUP_DIR/$dir" "$APP_DIR/"
        fi
      done
      
      # Restore user data files
      for file in "''${USER_DATA_FILES[@]}"; do
        if [ -f "$BACKUP_DIR/$file" ]; then
          echo "Restoring $file..."
          cp -a "$BACKUP_DIR/$file" "$APP_DIR/"
        fi
      done
      
      # Create a Portable file to tell Grayjay to use the current directory for data
      touch "$APP_DIR/Portable"
      
      # Clean up backup after successful restoration
      if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$BACKUP_DIR"
      fi
      
      echo "Grayjay update completed to version $PACKAGE_VERSION"
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