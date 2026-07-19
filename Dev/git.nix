# PowerManagement.nix
{ lib, config, pkgs, ... }:

let
  # Hardware-specific git configs
  gitConfigs = {
    isAsusTuf = {
      name = "Masrkai";
      email = config.identity.secrets.Masrkai_GitHub_Mail;
    };
    isDellG15 = {
      name = "maryam-othmann5";
      email = config.identity.secrets.Maryam_GitHub_Mail;
    };
  };

  # Select appropriate config
  userConfig =
    if config.hardware.isAsusTuf then gitConfigs.isAsusTuf
    else if config.hardware.isDellG15 then gitConfigs.isDellG15
    else throw "Undetected hardware: No matching hardware configuration found to configure git";

in

{
  imports = [
    ../ID/ID.nix
  ];

  #--> Git // LFS
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
      package = pkgs.git-lfs;
    };


    config = {
      user = userConfig;
      init.defaultBranch = "main";
    };

  };
}