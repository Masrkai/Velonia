{
  pkgs,
  lib,
  ...
}: {
  services.timesyncd.enable = false;
  time.hardwareClockInLocalTime = true;

  services.chrony = {
    enable = true;
    enableNTS = true;
    enableMemoryLocking = false;

    servers = []; # clear the default nixos pool servers
    #! NOTE: `iburst nts` IS AN ENFORCEMENT FOR THE USE OF NTS PROTOCOL for things to not get lose!
    extraConfig = ''

      # Force chrony to use eth0 (replace with your actual interface)
      # bindaddress 0.0.0.0


      server time.cloudflare.com iburst nts
      server ntppool1.time.nl iburst nts
      server nts.netnod.se iburst nts
      server ptbtime1.ptb.de iburst nts
    '';
  };

  services.ntpd-rs = {
    enable = false;
    useNetworkingTimeServers = true;
    settings.source =
      map (s: {
        mode = "nts";
        address = s;
      }) [
        "time.cloudflare.com"
        "ntppool1.time.nl"
        "nts.netnod.se"
        "ptbtime1.ptb.de"
      ];
  };

  systemd.services.geoclue.wantedBy = lib.mkForce []; # removes from default target
}

