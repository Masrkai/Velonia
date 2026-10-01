{ config, pkgs, ... }:


{
  services.minio = {
    enable = true;

    # Where MinIO stores your objects on disk
    dataDir = [ "/var/lib/minio/data" ];

    # The API port — this is what rclone and your app talk to
    listenAddress = "127.0.0.1:9000";

    # The web console port — browse buckets visually in browser
    consoleAddress = "127.0.0.1:9001";

    # Credentials loaded from a file outside the nix store
    # so secrets are never world-readable or committed to git
    # rootCredentialsFile = "/etc/minio/credentials";
  };

  # Create the credentials file content via a separate secret mechanism
  # The file at /etc/minio/credentials must contain exactly:
  #
  #   MINIO_ROOT_USER=youradminuser
  #   MINIO_ROOT_PASSWORD=yourpassword
  #
  # Create it manually on first setup:
  #   sudo mkdir -p /etc/minio
  #   sudo nano /etc/minio/credentials
  #   sudo chmod 600 /etc/minio/credentials

  # Open firewall for MinIO ports — only if you need LAN access
  # For local dev where everything is on localhost, skip this
  # networking.firewall.allowedTCPPorts = [ 9000 9001 ];

  # Ensure the data directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /var/lib/minio/data 0750 minio minio -"
    "d /etc/minio 0750 root root -"
  ];

  environment.systemPackages = with pkgs; [
    rclone

  ];

}
