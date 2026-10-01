{ config, pkgs, lib, ... }:

#*#########################
#* Networking-Configuration:
#*#########################
{

  imports = [
    ./DNS/ztop.nix
    ./Profiles/ztop.nix
    ./Protocols/ztop.nix
    ./hardening/ztop.nix

    ./Firewall.nix
    ./TimeSync.nix
    ./cloudflare-warp.nix
    ./Wireless_Regulation.nix

  ];


  services.nscd.enable = false; system.nssModules = lib.mkForce [];   #> TESTING, As i think it's not needed as unbound is used for caching
  systemd.services.ModemManager.enable = false;                       #> This is for Cellular networks like 5G,4G PLEASE ENABLE THIS in case you need it, i don't so i won't
  systemd.services.NetworkManager-dispatcher.enable = false;          #> IF you have or rely or will do scripts, PLEASE ENABLE THIS i don't so i won't.
  systemd.services.NetworkManager-wait-online.enable = false;         #? takes 6 secs and is not necessary at all!

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = config.identity.hostname;
    enableIPv6 = false;
    nftables.enable = true;
    usePredictableInterfaceNames = false;

    # Disable conflicting DHCP service
    dhcpcd.enable = false;

    # Disable resolvconf to prevent conflicts with the custom DNS
    resolvconf.enable = false;

    # Set your DNS servers explicitly
    nameservers = [ "127.0.0.1" ];

    networkmanager = {
      # Let your custom DNS handle resolution
      dns = "default";
      dhcp = "internal";
      # dhcp = "dhcpcd";
      enable = true;
      logLevel = "INFO";
      ensureProfiles.environmentFiles = [ "/etc/nixos/Sec/network-manager.env" ];

      wifi.powersave = false;
      ethernet.macAddress = "random";
      wifi.scanRandMacAddress = true;

      plugins = with pkgs; [
        networkmanager-openvpn
      ];

      settings = {
        connection = {
          "connection.llmnr" = 1;
          "connection.mdns" = 1;
        };
      };
    };
  };

  services.hostapd = {
    enable = false;
    package = pkgs.hostapd;
  };


  environment.systemPackages = with pkgs; [
    wgcf
  ];

}