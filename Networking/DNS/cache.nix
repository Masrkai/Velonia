{
  pkgs,
  lib,
  ...
}: let
  # NTS server hostnames used by chrony. These must resolve even with a wrong
  # clock: they are excluded from DNSSEC validation and forwarded over plain
  # DNS (no TLS handshake, which would fail with skewed certificate dates).
  # Worst case an attacker makes resolution fail - chrony still verifies the
  # server's TLS identity before trusting any time.
  ntsHosts = [
    "time.cloudflare.com"
    "ntppool1.time.nl"
    "nts.netnod.se"
    "ptbtime1.ptb.de"
  ];

  # connection id (must match the profile `id`) -> internal domains allowed from that network's DHCP
  internalDomains = {
    "GU-Dorms" = ["gu.edu.eg"];
    "Gu_EMP" = ["gu.edu.eg"];
    "GU-Wifi" = ["gu.edu.eg"];
    "Library" = ["gu.edu.eg"];
  };

  caseArms = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (name: domains: ''"${name}") allowed="${lib.concatStringsSep " " domains}" ;;'')
    internalDomains);

  adblockLocalZones = pkgs.stdenv.mkDerivation {
    name = "unbound-zones-adblock";

    src =
      pkgs.fetchFromGitHub {
        owner = "StevenBlack";
        repo = "hosts";
        rev = "3.16.112";
        sha256 =
          # lib.fakeHash;
          "sha256-z3ZXPW4NyK1ZEv/9Q05zObQjzcH187ROkyRIZ8holJQ=";
      }
      + "/hosts";

    phases = ["installPhase"];

    installPhase = ''
      ${pkgs.gawk}/bin/awk '{sub(/\r$/,"")} {sub(/^127\.0\.0\.1/,"0.0.0.0")} BEGIN { OFS = "" } NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" static"}' $src | tr '[:upper:]' '[:lower:]' | sort -u >  $out
    '';
  };
in {
  #> DNS Caching using Unbound
  services.unbound = {
    enable = true;
    stateDir = "/var/lib/unbound";
    localControlSocketPath = "/run/unbound/unbound.ctl";
    # extraConfig = ''
    #   include: "${adblockLocalZones}"
    #     '';

    settings = {
      server = {
        interface = [
          # "0.0.0.0"
          "127.0.0.1@53" # Listen on localhost
          # "192.168.123.1@53"  # Listen on hotspot interface
          # "192.168.125.1@53"  # Listen on hotspot interface
        ];

        # interface-automatic = "yes";

        access-control = [
          "0.0.0.0/0 refuse" # Refuse all other networks by default

          "10.0.0.0/8 allow" # Another private network range
          "192.0.0.0/8 allow" # Private network range
          "172.16.0.0/12 allow" # Another private network range
          "192.168.0.0/16 allow" # Common home/local network range

          "127.0.0.0/8 allow" # Localhost
          "192.168.125.0/24 allow" # Allow hotspot clients
          "192.168.123.1/24 allow" # Listen on hotspot interface
        ];

        private-address = [
          "192.168.0.0/16"
          "127.0.0.0/8"
        ];
        private-domain = [
          "local"
          "localhost"
          "internal"
        ];

        so-reuseport = "yes";
        # tls-cert-bundle= /etc/ssl/certs/ca-certificates.crt;
        include = [
          "${adblockLocalZones}"
        ];

        # Performance and caching optimization settings
        num-threads = 4;
        msg-cache-slabs = 4;
        rrset-cache-slabs = 4;
        infra-cache-slabs = 4;
        key-cache-slabs = 4;

        # Extended caching configuration
        prefetch = "yes";
        prefetch-key = "yes";
        rrset-roundrobin = "yes";

        # Significantly extended cache times
        cache-min-ttl = 300; # Minimum 5 minutes (extended from 60 seconds)
        cache-max-ttl = 604800; # 7 days maximum cache (extended from 24 hours)
        serve-expired = "yes"; # Serve expired records while refreshing
        serve-expired-ttl = 14400; # Serve expired records for up to 4 hours (extended from 1 hour)

        # Increased cache sizes
        msg-cache-size = "512m"; # Increased from 128m
        rrset-cache-size = "1024m"; # Increased from 256m
        key-cache-size = "256m"; # Increased from 128m
        neg-cache-size = "128m"; # Increased from 32m for longer negative caching

        # Fault tolerance and connection settings
        tcp-idle-timeout = 60000; # Increased from 30000 to keep connections alive longer

        # Protocol and security settings (maintained)
        do-ip4 = "yes";
        do-ip6 = "no";
        do-udp = "yes";
        do-tcp = "yes";

        hide-identity = "yes";
        hide-version = "yes";

        harden-glue = "yes";
        harden-referral-path = "yes";
        harden-algo-downgrade = "yes";
        harden-below-nxdomain = "yes";
        harden-dnssec-stripped = "yes";

        use-caps-for-id = "no";
        qname-minimisation = "yes";

        # No DNSSEC validation for the NTS server names only - everything else
        # keeps full validation (fail closed with a wrong clock is the point).
        domain-insecure = ntsHosts;

        # Minimal logging for performance
        verbosity = 0;
        log-queries = "no";
        log-replies = "no";
        log-servfail = "yes"; # only log failures, that's what matters
        statistics-interval = 0;
      };

      forward-zone =
        [
          {
            name = ".";
            forward-addr = "127.0.0.1@5354"; # dnscrypt-proxy's local port
            forward-first = "yes";
            # forward-tls-upstream = "yes";
          }
        ]
        ++ map (h: {
          # NTS hostnames: plain DNS to Quad9, no TLS, no clock needed.
          name = "${h}.";
          forward-addr = [
            "9.9.9.9"
            "149.112.112.112"
          ];
          forward-first = "yes";
        })
        ntsHosts;
    };
  };

  # DHCP-provided internal domains are only forwarded on trusted networks:
  # the connection id gates which domains may be added, and each zone is
  # checked against that network's allowlist before forwarding.
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "unbound-dhcp-forward" ''
        uc="${pkgs.unbound}/bin/unbound-control -s /run/unbound/unbound.ctl"
        state=/run/unbound-dhcp
        iface="$1"
        mkdir -p "$state"

        remove_old() {
          [ -f "$state/$iface" ] || return 0
          while read -r z; do
            $uc forward_remove +i "$z"
            $uc flush_zone "$z"
          done < "$state/$iface"
          rm -f "$state/$iface"
        }

        case "$2" in
          up|dhcp4-change)
            remove_old

            case "$CONNECTION_ID" in
              ${caseArms}
              *) exit 0 ;;
            esac

            servers="''${DHCP4_DOMAIN_NAME_SERVERS:-}"
            [ -n "$servers" ] || exit 0

            for z in ''${DHCP4_DOMAIN_NAME:-} ''${DHCP4_DOMAIN_SEARCH:-}; do
              z="''${z%.}"
              case " $allowed " in *" $z "*) ;; *) continue ;; esac
              $uc forward_add +i "$z" $servers
              $uc flush_zone "$z"
              echo "$z" >> "$state/$iface"
            done
            ;;
          down)
            remove_old
            ;;
        esac
      '';
    }
  ];
}
