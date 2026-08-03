{pkgs, ...}:

{
  imports = [
    # commented out because of "no longer needed" reasons but keeping configs just in case
    # ./android.nix
    # ./big_data.nix
    # ./jupyter.nix

    # SWE Toolkits
    ./UML.nix
    ./Docs.nix
    ./GUIs.nix
    ./embedded.nix
    ./image_processing.nix

    # Databases / Storage Buckets / Data Queries
    ./DBs/query.nix
    ./DBs/sqlite.nix

    ./DBs/neo4j.nix
    ./DBs/arcadedbserv.nix

    ./DBs/MySQL.nix
    ./DBs/PostgreSQL.nix

    ./DBs/storagebucket.nix

    ./performance_analysis.nix
  ];

}
