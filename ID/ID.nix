# ID.nix - Hardware detection & identity config
{ lib, config, pkgs, ... }:

let
  localSecrets = import ../Sec/secrets.nix;

  # Global configuration - change this path if needed
  hardwareConfigFile = "/etc/nixos/Sec/hardware-detected.nix";

  # Path to the detection script
  detectScript = ./detect-hardware.sh;

in {

  imports=[
      # Auto-import the generated hardware config
    (if builtins.pathExists /etc/nixos/Sec/hardware-detected.nix
    then /etc/nixos/Sec/hardware-detected.nix
    else {})

  ];


  options = {
    identity = {
      username = lib.mkOption {
        type = lib.types.str;
        default = localSecrets.username;
        description = "Primary username for the system";
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        default = localSecrets.hostname;
        description = "System hostname";
      };

      secrets = lib.mkOption {
        type = lib.types.raw;
        default = localSecrets;
        description = "Sensitive configuration values from Sec/secrets.nix";
      };
    };

    hardware = {
      isAsusTuf = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is an ASUS TUF Gaming laptop";
      };

      isIdeaPad5 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a LENOVO IdeaPad 5 laptop";
      };

      isThinkPad = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a ThinkPad laptop";
      };

      isDellG15 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a Dell laptop";
      };
    };
  };

  config = {
    system.activationScripts.detectHardware = {
      text = ''
        ${pkgs.bash}/bin/bash ${detectScript} ${hardwareConfigFile}
      '';
      deps = [ ];
    };
  };
}