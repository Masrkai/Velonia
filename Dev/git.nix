# git.nix
{
  lib,
  config,
  pkgs,
  ...
}: let
  gitConfigs = {
    Masrkai = {
      name = "Masrkai";
      email = config.identity.secrets.Masrkai_GitHub_Mail;
    };
    maryam-othmann5 = {
      name = "maryam-othmann5";
      email = config.identity.secrets.Maryam_GitHub_Mail;
    };
  };

  # Unchanged in intent: pick identity by hardware. IdeaPad5 is not mapped in
  # your original either, so it still hits the throw below. Add it to a branch
  # if that machine should commit as one of these identities.
  userConfig =
    if config.hardware.isAsusTuf || config.hardware.isThinkPad
    then gitConfigs.Masrkai
    else if config.hardware.isDellG15
    then gitConfigs.maryam-othmann5
    else throw "Undetected hardware: No matching hardware configuration found to configure git";
in {
  # ID.nix is imported by IDEs/default.nix as well. The module system
  # de-duplicates identical imports, so importing it from both is safe.
  imports = [
    ../ID/ID.nix
  ];

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
