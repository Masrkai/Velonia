{ config, lib, pkgs, modulesPath, ... }:

{

  #---> Qbit_torrent x Jackett
    services.jackett = {
      port = 9117;
      enable = true;
      package = pkgs.jackett;

      user = "jackett" ;
      group = "jackett" ;

      openFirewall = false;

      dataDir = "/var/lib/jackett/";
    };


}