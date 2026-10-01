{ config, pkgs, lib, ... }:

let
  USER_NAME = {
    user     = config.identity.username;
  };
in {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/var/lib/mysql";

    user = USER_NAME.user;
    group = "mysql";

    ensureUsers = [{
      name = USER_NAME.user;
      # password = USER_NAME.password;
      ensurePermissions = {
        "*.*" = "ALL PRIVILEGES";  # Correct database (mainDB.*)
      };
    }];

    settings = {
      mysqld = {
        port = 3306;  # Standard MySQL port
        bind-address = "127.0.0.1";
        socket = "/var/run/mysqld/mysqld.sock";

        max_connections = 200;

        # Connection timeout settings
        wait_timeout = 600;         # Timeout for non-interactive connections
        # interactive_timeout = 3600; # Timeout for interactive connections
        #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        # Performance tuning
        innodb_log_file_size = "64M";
        innodb_flush_method = "O_DIRECT";    # Better I/O performance on Linux
        innodb_buffer_pool_size = "256M";  # Adjust based on available RAM (usually 50-70% of RAM)
        innodb_flush_log_at_trx_commit = 1;  # 1 for ACID compliance, 2 for better performance

        # Temp tables and sorting
        tmp_table_size = "64M";
        join_buffer_size = "2M";
        sort_buffer_size = "4M";
        max_heap_table_size = "64M";


        # Query cache (disable for MariaDB 10.1.7+, as it can cause contention)
        query_cache_type = 0;
        query_cache_size = 0;
        #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        # Character set and collation
        character-set-server = "utf8mb4";
        collation-server = "utf8mb4_general_ci";

        # Logging
        log-error = "/var/log/mysql_err.log";
        slow_query_log_file = "/var/log/mysql_slow.log";

        slow_query_log = 1;
        long_query_time = 2;        # Log queries taking longer than 2 seconds

        sql_mode = "STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION";
        plugin-load-add = [ "server_audit" "ed25519=auth_ed25519" ];
      };
      #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      mysqldump = {
        quick = true;
        max_allowed_packet = "32M";
        single-transaction = true;  # Consistent dumps for InnoDB
      };
      #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      mysql = {
        # Default character set
        default-character-set = "utf8mb4";
      };

    };
  };

    systemd.services.mysql.wantedBy = lib.mkForce [];  # removes from default target

}