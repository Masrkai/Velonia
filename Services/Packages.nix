{  config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    lm-studio = pkgs.callPackage          ../Programs/Packages/lm-studio.nix { };
    logisim-evolution = pkgs.callPackage  ../Programs/Packages/logisim-evolution.nix { };
    super-productivity = pkgs.callPackage ../Programs/Packages/super-productivity.nix { };

    #? Masrkai built
    vera = pkgs.callPackage               ../Programs/masrkai-built/vera.nix { };
    # harper = pkgs.callPackage ./Programs/Packages/harbor.nix {};
  };
in
{

  environment.systemPackages = with pkgs; [

    ffmpeg-full

    #-> Custom
    grayjay

    #-> General
    acpi
    wget
    most
    sass

    gnome-network-displays
    # pure-ftpd

    unzip
    pciutils
    hw-probe
    unrar-wrapper
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
    arduino-ide
    arduino-core

    #-> Benchmarking
    furmark

    #-> Ai
    # lmstudio

    # koboldcpp

    #-> Monitoring
    htop
    btop
    powertop
    bandwhich
    dmidecode
    gsmartcontrol
    mission-center
    nvtopPackages.nvidia

    #-> Repair
    woeusb
    ntfs3g # ? Needed by woeusb
    #  ventoy  #! this is a security concern after the XZ utils events

    #-> Content
    kew
    yt-dlp
    haruna
    amberol
    qbittorrent

    ani-cli
    mpv # ! Needed for ani-cli operation

    brave
    # mellowplayer
    keepassxc
    fastfetch
    authenticator
    signal-desktop

    #-> Archivers
    pv
    zstd
    # pigz
    tarlz
    # p7zip

    #-> Audio
    pamixer
    alsa-tools
    pavucontrol

    #-> Maintenance Utilities
    gparted # !has issues
    qdiskinfo
    gnome-disk-utility

    #-> System Utilities
    file
    ethtool
    mlocate
    busybox
    pciutils

    #-> KDE Specific
    kdePackages.kclock
    kdePackages.kgamma
    kdePackages.kscreen
    kdePackages.kdenlive
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

    customPackages.logisim-evolution

    customPackages.vera

  ];

}
