{ config, lib, pkgs, ... }:

{

  #--> NextCloud
  environment.etc."nextcloud-admin-pass".text = config.identity.secrets.nextcloud-admin-pass;
  services.nextcloud = {
    enable = false;
    package = pkgs.nextcloud30;

    extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
      };

    hostName = "NixOS";
    config.dbtype = "sqlite";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
  };
}