{ config, lib, pkgs, ... }:

{
    services.journald = {
    # Controls repeated message filtering
    rateLimitInterval =
      config.identity.secrets.journald.Interval;

    rateLimitBurst =
      config.identity.secrets.journald.LimitBurst;

    extraConfig = ''
      # Compress logs to save space
      Compress=${config.identity.secrets.journald.compress}

      # Optional: Set max log size and retention
      SystemMaxUse=${config.identity.secrets.journald.MaxUse}
      MaxRetentionSec=${config.identity.secrets.journald.RetentionSec}
    '';
    };


}
