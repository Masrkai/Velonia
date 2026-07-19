{ config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    #? .Nix
    lm-studio = pkgs.callPackage ./Programs/Packages/lm-studio.nix {};
    logisim-evolution = pkgs.callPackage ./Programs/Packages/logisim-evolution.nix {};
    super-productivity = pkgs.callPackage ./Programs/Packages/super-productivity.nix {};
    vera = pkgs.callPackage Programs/masrkai-built/vera.nix {};


    # # harper = pkgs.callPackage ./Programs/Packages/harbor.nix {};
    # harper = pkgs.callPackage (fetchFromGitHub {
    #   owner = "Masrkai";
    #   repo = "Harper";
    #   rev = "3ae33ba533d4a750cdcf0d8d1da59999d6168e83";
    #   # hash = "";  # run once, copy hash from error, then add
    # }) { };

    # harper = let
    #   harperSrc = pkgs.fetchFromGitHub {
    #     owner = "Masrkai";
    #     repo  = "Harper";
    #     rev   = "3ae33ba533d4a750cdcf0d8d1da59999d6168e83";
    #     hash  = "sha256-hakvoMKgxKjjsxzMsf9ibyRyZm8LZD7x8TIaX+JtT0M=";
    #     # hash  = lib.fakeHash;   # replace with real hash after first build error
    #   };
    # in pkgs.callPackage "${harperSrc}/default.nix" { src = harperSrc; };


    #>! Binary / FHSenv
    # proton-ge-bin = pkgs.callPackage ./Programs/Packages/proton-ge-bin.nix {};
    # grayjay-bin = pkgs.callPackage ./Programs/Packages/grayjay-desktop/grayjay-bin2.nix {};
  };
in
{
    imports = [
      ./nix-system.nix
      ./control-hardware.nix


      ./desktop.nix
      ./systemd.nix
      ./graphics.nix
      ./security.nix
      ./Dev/ztop.nix
      ./Services/ztop.nix
      ./Terminal/bash.nix
      ./Programs/custom/ztop.nix
      ./Networking/Networking.nix
    ];


  time.timeZone = config.identity.secrets.TZ;
  identity.secrets = import ./Sec/secrets.nix;
  i18n={
    #? Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";

    extraLocales =  [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
      "ar_EG.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];

    supportedLocales = [
     "all"
    ];

    extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
  }; };


  fonts = {
    packages = with pkgs; [

      #* Terminal Icons
      nerd-fonts.symbols-only  # all nerd font icons, no patched base font

      #* First Class
      amiri
      iosevka-bin
      cm_unicode
      newcomputermodern

      #> Second Class
      dejavu_fonts
      liberation_ttf

        # Corporate fonts
        vista-fonts
        corefonts

        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "Iosevka Fixed Hv Ex Obl" "Iosevka" "Nerd Fonts Symbols Only" ];
          sansSerif   = [ "Iosevka Fixed Hv Ex Obl" "Iosevka" "DejaVu Sans" ];
          serif       = [ "Iosevka Fixed Hv Ex Obl" "Iosevka" "DejaVu Serif" ];

          # Always keep Emoji separate, otherwise you get boxes for emojis
          emoji       = [ "Noto Color Emoji" ];
        };
      };
  };

    users.users.${config.identity.username} = {
        isNormalUser = true;
        description = "Masrkai";
        extraGroups = [
                        "wheel"
                        "networkmanager" "bluetooth"
                        "wireshark"
                        "qbittorrent" "jackett"
                        "video" "audio" "power"
                        "ollama"
                        # "libvirtd" "kvm" "ubridge"  #* Virtualization

                        "tty" "dialout"             #* Allow access to serial device (for Arduino dev)
                      ];
      };


  #! Disable flatpack
  services.flatpak.enable = lib.mkForce false;





 environment.systemPackages = with pkgs; [
  #*############
  #*Development:
  #*############

ffmpeg-full

  #-> Custom
  pkgs.grayjay
  customPackages.logisim-evolution

  kitty

  nix-prefetch-git
  nixos-generators

  #-> General
  bat
  eza
  acpi
  wget
  less
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


#?#############
#? User-Daily:
#?#############
  #-> Ai
  # lmstudio
  # customPackages.lm-studio   #? relying on custom package rather than nix packages because they are ancient in release

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
   ntfs3g #? Needed by woeusb
  #  ventoy  #! this is a security concern after the XZ utils events

  #-> Content
  kew
  fzf
  yt-dlp
  haruna
  amberol
  qbittorrent

  pkgs.ani-cli
    mpv               #! Needed for ani-cli operation


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
  gparted #!has issues
  pkgs.qdiskinfo
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
  customPackages.vera

];

  #?########################
  #? Applications services:
  #?########################

  gtk.iconCache.enable = true;

  #--> Appimages supports
  programs.appimage = {
  enable = true;
  binfmt = true;
  };

  #--> KDE connect
    programs.kdeconnect = lib.mkForce {
      enable = true;
      package =  pkgs.kdePackages.kdeconnect-kde;
    };


  #---> Enable CUPS to print documents.
  services.printing.enable = false;

  #--> NoiseTorch: Real-Time Microphone Noise Suppression
  programs.noisetorch.enable = true;

  system.stateVersion = "25.05";
}
