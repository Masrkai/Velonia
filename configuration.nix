{ config, lib, pkgs, modulesPath, ... }:


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
      ./Terminal/ztop.nix
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
        description = "default";
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
