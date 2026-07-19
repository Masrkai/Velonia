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
      devices = {
        "A71" = { id = "NINHMAQ-LAPJ3LN-OOGEWBE-TG3XIWL-LFI2TOT-BBLCPY3-ASLU3IE-AXGDHAE"; };
        "Tablet" = { id = "LFRE73C-E6RPZJG-MPBMNLA-422AN62-BSIJSLD-XJGZULE-B27ZY5W-L4O4WAY"; };
        "Mariam's Laptop G15" = { id ="XR63JZR-33WFJNB-PPHDMWF-XF3V5WX-34XHJAB-SIL2L7L-QGPZI2U-BKRIOQO";};
        "Essa's Lenovo" = { id ="SCJM6XL-YBBJOIQ-NIBOI2K-7EZK2DH-DDPREYU-GWTHEMY-VY6ARVE-XJRKVAM";};
        };
      folders = {


        "Backup" = {
          path = "~/Documents/Backup/";
          devices = [ "A71" "Tablet" ];
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
          devices = [ "A71" "Tablet" "Mariam's Laptop G15" "Essa's Lenovo"  ];
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
          devices = [ "A71" "Tablet" "Mariam's Laptop G15" "Essa's Lenovo" ];
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
          devices = [ "A71" ];
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