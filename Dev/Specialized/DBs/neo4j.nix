{ pkgs, lib, config, ... }:

{

  services.neo4j = {
    enable = false;

    # Network
    defaultListenAddress = "127.0.0.1";

    # Connectors
    http.enable = true;
    http.listenAddress = ":7474";

    https.enable = false;
    https.listenAddress = ":7473";

    bolt.enable = true;
    bolt.listenAddress = ":7687";
    bolt.tlsLevel = "DISABLED";  # DISABLED | OPTIONAL | REQUIRED

    # Directories (all default under /var/lib/neo4j)
    directories.home = "/var/lib/neo4j";
    directories.data = "/var/lib/neo4j/data";
    directories.imports = "/var/lib/neo4j/import";

    # Extra neo4j.conf lines
    extraServerConfig = ''
      server.memory.heap.max_size=2G
      server.memory.pagecache.size=1G
      dbms.security.auth_enabled=false
      dbms.usage_report.enabled=false
      client.allow_telemetry=false
    '';

    # Read-only mode
    readOnly = false;
  };

  systemd.services.neo4j.wantedBy = lib.mkForce [];  # removes from default target

  environment.systemPackages = lib.mkIf config.services.neo4j.enable (with pkgs; [
    neo4j
  # neo4j-desktop
  ]);

}
