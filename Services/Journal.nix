{ config, lib, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;
in

{
    services.journald = {
    # Controls repeated message filtering
    rateLimitInterval =
      secrets.journald.Interval;

    rateLimitBurst =
      secrets.journald.LimitBurst;

    extraConfig = ''
      # Compress logs to save space
      Compress=${secrets.journald.compress}

      # Optional: Set max log size and retention
      SystemMaxUse=${secrets.journald.MaxUse}
      MaxRetentionSec=${secrets.journald.RetentionSec}
    '';
    };


}
