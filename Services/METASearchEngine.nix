{ config, lib, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;
in


{
  #---> SearXNG

  services.redis = {
    package = pkgs.valkey;  # Use Valkey instead of Redis

    servers.searxng = {
      enable = true;
      port = 0;  # Disable TCP, use Unix socket only
      unixSocket = "/run/redis-searxng/redis.sock";  # Use the auto-created directory
      unixSocketPerm = 660;

      # Performance tuning for SearXNG
      settings = {
        maxmemory = "256mb";
        maxmemory-policy = "allkeys-lru";
        save = [];  # Empty list to disable persistence for cache
        databases = 16;
      };
    };
  };

  # Ensure SearXNG user can access the socket
  users.users.searx.extraGroups = [ "redis-searxng" ];  # Note: group name matches the server name

  services.searx = {
    enable = true;
    package = pkgs.searxng;

      faviconsSettings = {
        favicons = {
                cfg_schema = 1;

                  proxy = {
                    # Uncomment and modify as needed:
                    max_age = 5184000;  # 60 days / default: 7 days (604800 sec)

                    resolver_map = {
                      google     = "searx.favicons.resolvers.google";
                      yandex     = "searx.favicons.resolvers.yandex";
                      allesedv   = "searx.favicons.resolvers.allesedv";
                      duckduckgo = "searx.favicons.resolvers.duckduckgo";
                    };
                  };

                  cache = {
                    # Uncomment and modify as needed:
                    db_url = "/var/cache/searxng/faviconcache.db";  # default: "/tmp/faviconcache.db"
                    HOLD_TIME = 5184000;                            # 60 days / default: 30 days
                    LIMIT_TOTAL_BYTES = 268435456;                  # 2147483648;  # 2 GB
                                                                    # 268435456;   # 256 MB
                                                                    # default: 50 MB
                    BLOB_MAX_BYTES = 40960;                         # 40 KB / default 20 KB
                    MAINTENANCE_MODE = "off";                       # default: "auto"
                    MAINTENANCE_PERIOD = 600;                       # 10min / default: 1h
                  };
        };
      };

      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
        };
      };


      settings = {


    valkey = {
      url = "unix:///run/redis-searxng/redis.sock?db=0";  # Update socket path
    };




        general = {
          instance_name = "Masrkai";
        };

        brand = {
          docs_url         = "";
          wiki_url         = "";
          issue_url        = "";
          new_issue_url    = "";
          public_instances = "";
        };

        server = {
          port = 8880;
          bind_address = "127.0.0.1";
          base_url = "http://localhost/";
          secret_key = secrets.searx-secret-key;
          limiter = true;  # Enable rate limiting
          ratelimit_low = 30;
          ratelimit_high = 50;
        };

        ui = {
          site_name = "Masrkai";           # Browser tab title
          default_locale = "en";
          default_theme = "simple";
          query_in_title = true;
          infinite_scroll = true;
          engine_shortcuts = true;  # Show engine icons
          expand_results = true;    # Show result thumbnails
          theme_args = {
            style = "auto";  # Supports dark/light mode
          };
        };
        search = {
          safe_search = 0;
          default_lang = "en";
          autocomplete = "duckduckgo";
          favicon_resolver = "duckduckgo";

          suspend_on_unavailable = false;
            result_extras = {
            favicon = true;          # Enable website icons
            thumbnail = true;        # Enable result thumbnails
            thumbnail_proxy = true;  # Use a proxy for thumbnails
            };
            formats = [
              "rss"
              "csv"
              "html"
              "json"
            ];
        };

        plugins = let
          mkPlugin = name: active: { ${name} = { inherit active; }; };
          activePlugins = map (name: mkPlugin name true) [
            "searx.plugins.calculator.SXNGPlugin"
            "searx.plugins.hash_plugin.SXNGPlugin"
            "searx.plugins.self_info.SXNGPlugin"
            "searx.plugins.tracker_url_remover.SXNGPlugin"
            "searx.plugins.unit_converter.SXNGPlugin"
            "searx.plugins.hostnames.SXNGPlugin"
            "searx.plugins.oa_doi_rewrite.SXNGPlugin"

            # "searx.plugins.ahmia_filter.SXNGPlugin" # Deep web one
          ];
          inactivePlugins = map (name: mkPlugin name false) [
          ];
        in
          lib.foldr lib.mergeAttrs {} (activePlugins ++ inactivePlugins);

        engines = let
          mkEngine = idx: attrs: attrs // { shortcut = toString idx; };
        in lib.imap1 mkEngine [
          { name = "google";     engine = "google";     disabled = false; timeout = 6.0;  }
          { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; timeout = 6.0;  }
          { name = "brave";      engine = "brave";      disabled = false; timeout = 10.0; }

          { name = "wikipedia";  engine = "wikipedia";  disabled = false; timeout = 6.0; }

          #=== Books & Literature
          { name = "goodreads";    engine = "goodreads";     disabled = false; timeout = 6.0; }
          { name = "openlibrary";  engine = "openlibrary";   disabled = false; timeout = 6.0; }
          # { name = "annasarchive"; engine = "annas_archive"; disabled = false; timeout = 10.0; }

          #=== Software & Apps
          { name = "fdroid";              engine = "fdroid";          disabled = false; timeout = 6.0; }
          { name = "apkmirror";           engine = "apkmirror";       disabled = false; timeout = 6.0; }
          { name = "voidlinux";           engine = "voidlinux";       disabled = false; timeout = 6.0; }
          { name = "appleappstore";       engine = "apple_app_store"; disabled = false; timeout = 6.0; }
          { name = "cachyospackages";     engine = "cachy_os";        disabled = false; timeout = 6.0; }
          { name = "alpinelinuxpackages"; engine = "alpinelinux";     disabled = false; timeout = 6.0; }

          #=== Torrents
          { name = "bt4g";          engine = "bt4g";          disabled = false; timeout = 10.0; }
          { name = "1337x";         engine = "1337x";         disabled = false; timeout = 10.0; }
          { name = "btdigg";        engine = "btdigg";        disabled = false; timeout = 10.0; }
          { name = "kickass";       engine = "kickass";       disabled = false; timeout = 10.0; }
          { name = "piratebay";     engine = "piratebay";     disabled = false; timeout = 10.0; }
          { name = "solidtorrents"; engine = "solidtorrents"; disabled = false; timeout = 10.0; }
          { name = "tokyotoshokan"; engine = "tokyotoshokan"; disabled = false; timeout = 10.0; }

          #=== Wikis & Knowledge
          { name = "gentoo";                engine = "mediawiki";   disabled = false; timeout = 6.0; }
          { name = "wikibooks";             engine = "mediawiki";   disabled = false; timeout = 6.0; }
          { name = "wikiquote";             engine = "mediawiki";   disabled = false; timeout = 6.0; }
          { name = "wikisource";            engine = "mediawiki";   disabled = false; timeout = 6.0; }
          { name = "wikispecies";           engine = "mediawiki";   disabled = true;  timeout = 6.0; }
          { name = "minecraftwiki";         engine = "mediawiki";   disabled = true;  timeout = 6.0; }
          { name = "archlinuxwiki";         engine = "archlinux";   disabled = false; timeout = 6.0; }
          { name = "wikicommons.audio";     engine = "wikicommons"; disabled = false; timeout = 6.0; }
          { name = "wikicommons.files";     engine = "wikicommons"; disabled = false; timeout = 6.0; }
          { name = "wikicommons.images";    engine = "wikicommons"; disabled = false; timeout = 6.0; }
          { name = "wikicommons.videos";    engine = "wikicommons"; disabled = false; timeout = 6.0; }
          { name = "freesoftwaredirectory"; engine = "mediawiki";   disabled = false; timeout = 6.0; }

          #! Disabled
          { name = "bing";      engine = "bing";  disabled = true; timeout = 6.0; }
          { name = "openrepos"; engine = "xpath"; disabled = true; timeout = 6.0; }
          { name = "wikidata";   engine = "wikidata";   disabled = true;  timeout = 6.0; }  # Disabled - getting 403
          { name = "googleplayapps";      engine = "google_play";     disabled = true; timeout = 6.0; }
        ];

        outgoing = {
          pool_maxsize = 8;
          pool_connections = 16;


          enable_http2 = true;

          request_timeout = 12.0;
          max_request_timeout = 15.0;

          retries = 2;
          max_redirects = 5;
          keepalive_expiry = 10.0;

          dns_resolver = {
            enable = true;
            use_system_resolver = true;
            resolver_address = "127.0.0.1";
          };
        };


        cache = {
          cache_max_age = 1440;  # Cache for 24 hours
          cache_disabled_plugins = [];
          cache_dir = "/var/cache/searxng";
        };

        privacy = {
          preferences = {
            disable_map_search = true;
            disable_web_search = false;
            disable_image_search = false;
          };
          http_header_anonymization = true;
        };
      };
    };
}