{pkgs, config, ...}:

{
  services.jupyter = {
    enable = true;

    port = 8888;
    ip   = "127.0.0.1";

    password = "null";
    package = pkgs.python3Packages.jupyter-core;

  };




}