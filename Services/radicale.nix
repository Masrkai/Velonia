# radicale.nix
{ lib, config, pkgs, ... }:

{

  #! you need to run the following command manually:
  # sudo htpasswd -B -c /var/lib/radicale/key masrkai

  environment.systemPackages = with pkgs; [
    apacheHttpd
  ];

  services.radicale =
    {
    enable = true;
      settings = {
        server = {
          hosts = [
            "0.0.0.0:5232"
            "[::]:5232"
            ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/var/lib/radicale/key";
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };
      };
    };




}