{ config, pkgs, lib, ... }:

{

   services.gns3-server = {
    enable = true;
    package = pkgs.gns3-server;

      auth = {
        enable = false;
        user = config.identity.username;
          passwordFile = pkgs.writeTextFile {
          name = "gns3_password";
          text = config.identity.secrets.gns3_password;
          };
      };

      ssl = {
        enable = false;
        certFile = "/var/lib/gns3/ssl/cert.pem";
        keyFile = "/var/lib/gns3/ssl/key.pem";
      };

      settings = {
          Server ={
            port = 3080;
            host = "127.0.0.1";

            images_path = "~/GNS3/images";
            symbols_path = "~/GNS3/symbols";
            configs_path = "~/GNS3/configs";
            projects_path = "~/GNS3/projects";
            appliances_path = "~/GNS3/appliances";
          };
        };


   #! Supports:

      #? DHCP and ping
      vpcs = {
       enable = true;
       package = pkgs.vpcs;
      };

      #? cisco images emulation
      dynamips = {
       enable = true;
       package = pkgs.dynamips;
      };

      ubridge = {
       enable = true;
       package = pkgs.ubridge;
      };
   };

  systemd.services.gns3-server.serviceConfig = lib.mkForce {

    AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    PrivateUsers = false;

    ProtectHome = "no";
    ProtectSystem = "no";
  };

  environment.systemPackages = with pkgs; lib.optionals config.services.gns3-server.enable [
     gns3-gui
        #> needs:
        gns3-server

        #> Additionally:
        vpcs
        ubridge
        dynamips
      ];

}