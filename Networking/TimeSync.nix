{
  pkgs,
  lib,
  ...
}: {
  services.timesyncd.enable = false;
  time.hardwareClockInLocalTime = false;

  services.chrony = {
    enable = true;
    enableNTS = true;
    enableMemoryLocking = false;

    servers = []; # clear the default nixos pool servers
    #! NOTE: `iburst nts` IS AN ENFORCEMENT FOR THE USE OF NTS PROTOCOL for things to not get lose!
    extraConfig = ''

      # Force chrony to use eth0 (replace with your actual interface)
      # bindaddress 0.0.0.0

      # Break the boot-time deadlock: DNS+TLS need a sane clock, so let chrony
      # jump the clock (instead of slewing) if off by >1s during first 3 updates.
      makestep 1.0 3
      # Skip only certificate *date* checks until the first clock update; chain
      # and hostname are still verified, so a fake server can't hand us time.
      nocerttimecheck 1

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

  # Wait for chrony to sync, then clear DNS state poisoned by the wrong clock:
  # unbound's cached bogus results and dnscrypt-proxy's failed TLS sessions.
  # Relies on localControlSocketPath = "/run/unbound/unbound.ctl" (DNS/cache.nix).
  systemd.services.time-sync-recover = {
    description = "Reset DNS state once the clock is synchronized";
    wantedBy = ["multi-user.target"];
    after = ["chronyd.service" "unbound.service" "dnscrypt-proxy.service"];
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.chrony}/bin/chronyc waitsync 0 0.5 0 5 >/dev/null
      ${pkgs.unbound}/bin/unbound-control -s /run/unbound/unbound.ctl flush_bogus
      # Clear infra cache too: after clock-induced failures unbound may have
      # marked 127.0.0.1@5354 (dnscrypt-proxy) as unresponsive and back off
      # for minutes even though it's fine now.
      ${pkgs.unbound}/bin/unbound-control -s /run/unbound/unbound.ctl flush_infra all
      ${pkgs.systemd}/bin/systemctl restart dnscrypt-proxy.service
    '';
  };
}

