# dnscrypt-proxy2.nix
{ pkgs, lib, ... }:

{
  #> DNS-over-HTTPS/DNSCrypt via dnscrypt-proxy2
  # NOTE: service was renamed from dnscrypt-proxy2 → dnscrypt-proxy in recent NixOS
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      # Listen on a non-standard port so unbound can sit on :53 and forward here
      listen_addresses = [ "127.0.0.1:5354" ];

      # -----------------------------------------------------------------------
      # Server selection
      # -----------------------------------------------------------------------
      # Don't hardcode only cloudflare/google — in some environments they're
      # blocked. By leaving server_names commented out, dnscrypt-proxy will
      # automatically benchmark and pick the best reachable server from the
      # downloaded list that matches the requirements below.
      #
      # If you *do* want to prefer specific servers but still fall back:
      server_names = [ "cloudflare" "google" "quad9-doh-ip4-nofilter-pri" "mullvad-base" ];
      #
      # Requirements for auto-selected servers:
      ipv4_servers    = true;
      ipv6_servers    = false;  # set to true if you have IPv6 connectivity
      dnscrypt_servers = true;  # also accept DNSCrypt servers (not just DoH)
      doh_servers     = true;

      require_dnssec   = true;  # must validate DNSSEC (mirrors stubby's dnssec setting)
      require_nolog    = true;  # privacy: no-log servers only
      require_nofilter = true;  # don't use servers that enforce their own blocklist

      # -----------------------------------------------------------------------
      # Bootstrap / fallback (used only to resolve DoH server hostnames on
      # first start before cache exists; never used for user queries)
      # Use Quad9 + a couple others so we're not dependent on cloudflare being
      # reachable even for bootstrapping.
      # -----------------------------------------------------------------------
      bootstrap_resolvers = [
        "9.9.9.9:53"
        "149.112.112.112:53"
        "8.8.8.8:53"
      ];
      ignore_system_dns = true;  # don't use /etc/resolv.conf for bootstrap

      # -----------------------------------------------------------------------
      # Connection & performance
      # -----------------------------------------------------------------------
      timeout          = 2500;   # ms — mirrors stubby's 2000ms timeout
      keepalive        = 30;     # HTTP keepalive for DoH (seconds)
      max_clients      = 250;
      # Force TCP to improve reliability in restrictive environments
      # (some networks block UDP 443; TCP is harder to block)
      # force_tcp = true;        # uncomment if you're in a very restrictive env

      # TLS session tickets off = slightly more privacy, slightly more latency
      # tls_disable_session_tickets = false;

      # Ephemeral keys for DNSCrypt (new key per query — more private, slight perf cost)
      dnscrypt_ephemeral_keys = true;

      # -----------------------------------------------------------------------
      # Cache — DISABLED because unbound handles caching
      # Enabling both would cause double-caching and cache invalidation issues
      # -----------------------------------------------------------------------
      cache = false;

      # -----------------------------------------------------------------------
      # Logging — minimal
      # -----------------------------------------------------------------------
      log_level = 2;  # 0=debug … 6=fatal; 2=info is a good balance
      # Uncomment to log queries (useful for debugging):
      # query_log.file = "/var/log/dnscrypt-proxy/query.log";

      # -----------------------------------------------------------------------
      # Privacy / security extras
      # -----------------------------------------------------------------------
      block_ipv6       = false;     # unbound already sets do-ip6=no
      block_unqualified = true;     # don't leak single-label names upstream
      block_undelegated = true;     # don't leak queries for undelegated TLDs

      # Pad DNS queries to a multiple of this block size (hides query length)
      # 128 bytes — same as stubby's tls_query_padding_blocksize
      # padding_size = 128;

      # -----------------------------------------------------------------------
      # Resolver list sources
      # Multiple URLs = redundancy if one CDN is blocked
      # -----------------------------------------------------------------------
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file  = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;  # hours
      };

      # Optionally also pull the relay list for Anonymized DNSCrypt
      # (relays hide your IP from the resolver — like a lightweight Tor for DNS)
      # sources.relays = {
      #   urls = [
      #     "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
      #     "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
      #   ];
      #   cache_file   = "/var/cache/dnscrypt-proxy/relays.md";
      #   minisign_key  = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      #   refresh_delay = 72;
      # };

      # Anonymized DNS routing rules (requires relays source above)
      # anonymized_dns = {
      #   routes = [
      #     { server_name = "*"; via = [ "anon-*" ]; }
      #   ];
      #   skip_incompatible = false;
      # };
    };
  };

  # Ensure the cache directory exists
  # systemd.tmpfiles.rules = [
  #   "d /var/cache/dnscrypt-proxy 0755 root root -"
  # ];
}