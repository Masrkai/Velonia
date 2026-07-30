{ pkgs, lib, ... }:


{

  services.cloudflare-warp = {
    enable = true;
  };

  # Override the systemd service environment to reduce verbosity
  systemd.services.cloudflare-warp = {
    environment = {
      RUST_LOG = "warn";
      RUST_BACKTRACE = "0";
    };
    serviceConfig = {
      LogLevelMax = "warning";
    };
  };

  #? testing this you can run
  #> curl https://cloudflare.com/cdn-cgi/trace

}