{  config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    jsql = pkgs.callPackage ../Programs/Packages/jsql.nix { };

    wifi-honey = pkgs.callPackage ../Programs/Packages/wifi-honey.nix { };
    hostapd-wpe = pkgs.callPackage ../Programs/Packages/hostapd-wpe.nix { };
  };
in
{

  #--> Wireshark
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  #-> Ghidra
  programs.ghidra = {
    enable = true;
    gdb = true;

  };

  environment.systemPackages = with pkgs; [

    #!####################
    #! Pentration-Testing:
    #!####################
    #> Excution
    strace
    ltrace

    #> Password cracking
    crunch
    hashcat
    hcxtools
    hcxdumptool
    zip2hashcat
    hashcat-utils

    #> Internet basics
    iw
    dig
    nmap
    # unstable.nmapsi4
    rustscan
    getdns
    linssid
    tcpdump
    ettercap
    (lib.lowPrio iproute2)
    arp-scan
    inetutils
    traceroute

    ligolo-ng

    bettercap
    burpsuite

    #> DoS
    hping
    dsniff

    #> Wireless
    mdk4
    airgorah
    aircrack-ng
    linux-wifi-hotspot

    #> WPS
    bully
    pixiewps
    reaverwps-t6x

    #> MITM
    # customPackages.beef
    customPackages.wifi-honey

    #> Utilities
    tmux
    asleap
    lighttpd

    #> Memory
    pkgs.pince

    #> Exploitation
    # armitage
    exploitdb
    pkgs.metasploit
    armitage

    #> SQL
    sqlmap
    customPackages.jsql

    #> Evil Twin
    dnsmasq
    dhcpcd
    cni-plugins
    customPackages.hostapd-wpe

    foremost

    (lib.setPrio 1 bind)

    #> Encryption
    gnupg

    bloodhound

  ];

}
