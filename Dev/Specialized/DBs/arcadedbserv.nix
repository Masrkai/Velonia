{ config, pkgs, ... }:

let
  arcadedb = pkgs.callPackage ./arcadedb.nix {
    jre_headless = pkgs.openjdk21_headless;
  };
in
{
  environment.systemPackages = [ arcadedb ];

  users.users.arcadedb = {
    isSystemUser = true;
    group = "arcadedb";
  };
  users.groups.arcadedb = {};

  # The root password is NOT in this file. Create it once, root-only:
  #
  #   sudo mkdir -p /etc/arcadedb
  #   echo 'ARCADEDB_ROOT_PASSWORD=change-me' | sudo tee /etc/arcadedb/credentials
  #   sudo chmod 600 /etc/arcadedb/credentials
  #
  # Anything in `Environment = [...]` is copied into the world-readable Nix
  # store and shown by `systemctl show`, so secrets must not go there.
  systemd.services.arcadedb = {
    description = "ArcadeDB Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    # JAVA_OPTS is expanded by the shell in a wrapper below so the password is
    # read from the environment file at start time, never written into the unit.
    script = ''
      export JAVA_OPTS="-Xmx2g -Xms512m -Darcadedb.home=/var/lib/arcadedb -Darcadedb.server.rootPassword=$ARCADEDB_ROOT_PASSWORD"
      exec ${arcadedb}/bin/arcadedb-server
    '';

    serviceConfig = {
      Type = "simple";
      User = "arcadedb";
      Group = "arcadedb";
      WorkingDirectory = "/var/lib/arcadedb";
      StateDirectory = "arcadedb";
      EnvironmentFile = "/etc/arcadedb/credentials";
      Environment = [ "ARCADEDB_HOME=${arcadedb}/opt/arcadedb" ];
      Restart = "on-failure";
    };
  };

  networking.firewall.allowedTCPPorts = [
    2480 # HTTP / Studio
    2424 # binary protocol
    5432 # PostgreSQL wire protocol
    7687 # Bolt
  ];
}
