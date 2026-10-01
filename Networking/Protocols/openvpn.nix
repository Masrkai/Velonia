{pkgs, ...}:

{
  #> OpenVPN
  programs.openvpn3 = {
    enable = true;
    package = pkgs.openvpn3;

    # Configure logging
    log-service.settings = {
      log_level = 7;  # Info level
      journald = true;
    };

    # Configure DNS integration
    netcfg.settings = {
      systemd_resolved = false;
    };
  };

  environment.systemPackages = with pkgs; [
     easyrsa
     openssl
     ];
}