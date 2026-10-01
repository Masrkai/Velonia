{ config, lib, pkgs, modulesPath, ... }:

{

  #---> Syncthing
  services.syncthing = {
        enable = true;
        user = config.identity.username;
        dataDir = "/home/${config.identity.username}";
        configDir = "/home/${config.identity.username}/.config/syncthing";

    guiAddress = "127.0.0.1:8384";
    systemService = true;
    overrideDevices = true; #! Overrides devices added or deleted through the WebUI
    overrideFolders = true; #! Overrides folders added or deleted through the WebUI
    openDefaultPorts = true;
    settings = {
      options ={
        urAccepted = -1;
        relaysEnabled = false;
        maxFolderConcurrency = 9;
        localAnnounceEnabled = true;

      };

      devices = lib.listToAttrs (map (dev: {
        name = dev.name;
        value = { inherit (dev) id; };
      }) (builtins.attrValues config.identity.secrets.syncthingDevices));

      folders = {


        "Backup" = {
          path = "~/Documents/Backup/";
          devices = config.identity.secrets.syncthingFolders.Backup;
          versioning = {
            type = "simple";
              params = {
              keep = "1";
              };
          };
          type = "sendonly"; # Make folder send-only
        };



        "College_shit" = {
          path = "~/Documents/College/Current/";
          devices = config.identity.secrets.syncthingFolders.College_shit;
          versioning = {
            type = "simple";
              params = {
              keep = "1";
              };
          };
          type = "sendonly"; # Make folder send-only

          ignorePatterns = [
          ".git"
          "*/.venv"
          "*.gguf"
          "*.safetensors"
          ];
        };


        "Forbidden_Knowledge" = {
          path = "~/Documents/Books/";
          devices = config.identity.secrets.syncthingFolders.Forbidden_Knowledge;
          versioning = {
            type = "simple";
              params = {
              keep = "5";
              };
          };
          type = "sendonly"; # Make folder send-only
        };



        "Music" = {
          path = "~/Music/";
          devices = config.identity.secrets.syncthingFolders.Music;
          ignorePerms = false;
          # Add ignore patterns here
          ignorePaths = [
          # Common patterns
          ".git"
          "*.tmp"
          "*.temp"
          "node_modules"
          #? Music crap

          "/Telegram"
          ".thumbnails"
          "/.thumbnails"
          ];
        };


      };
    };
  };


}