{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  customPackages = {
    lm-studio = pkgs.callPackage ../Programs/Packages/lm-studio.nix {};
    logisim-evolution = pkgs.callPackage ../Programs/Packages/logisim-evolution.nix {};
    super-productivity = pkgs.callPackage ../Programs/Packages/super-productivity.nix {};

    #? Masrkai built
    vera = pkgs.callPackage ../Programs/masrkai-built/vera.nix {};
    harper = pkgs.callPackage ../Programs/masrkai-built/harper.nix {};
  };
in {
  programs.iotop = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    customPackages.harper

    ffmpeg-full

    # grayjay

    #-> General
    sass

    gnome-network-displays
    # pure-ftpd

    rustdesk-flutter
    # (lib.lowPrio bash-completion)

    #-> Engineering
    kicad
    #freecad

    #-> Phone
    scrcpy
    android-tools

    #-> MicroChips
    esptool
    usbutils
    # arduino-ide
    # arduino-core

    arduino-cli

    #-> Benchmarking
    furmark

    #-> Monitoring
    gsmartcontrol
    mission-center

    #-> Repair
    woeusb
    ntfs3g # ? Needed by woeusb
    #  ventoy  #! this is a security concern after the XZ utils events

    lm_sensors

    #-> Content
    kew
    yt-dlp
    haruna
    amberol
    qbittorrent

    ani-cli
    mpv # ! Needed for ani-cli operation

    readest

    keepassxc
    authenticator
    signal-desktop

    #-> Audio
    alsa-tools
    pavucontrol

    #-> Maintenance Utilities
    gparted # !has issues

    parted
    qdiskinfo
    gnome-disk-utility

    #-> KDE Specific
    kdePackages.kclock
    kdePackages.kgamma
    kdePackages.kscreen
    #    kdePackages.kdenlive

    kdePackages.partitionmanager
    kdePackages.skanlite
    kdePackages.filelight
    kdePackages.colord-kde
    kdePackages.breeze-icons
    kdePackages.kscreenlocker
    kdePackages.plasma-browser-integration

    #-> Productivity
    gimp
    inkscape-with-extensions
    affine
    # kooha
    # blender
    # davinci-resolve
    thunderbird-bin
    libreoffice-qt6-still
    hunspell
    hunspellDicts.en_US

    #-> PDF
    pdfarranger
    pdfmixtool

    mindustry-wayland

    #Spell_check
    aspell
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers

    btrfs-progs
    # customPackages.harper

    customPackages.vera
    customPackages.logisim-evolution

    cryptsetup
  ];
}
