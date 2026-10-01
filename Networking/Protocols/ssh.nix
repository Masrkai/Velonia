{ lib, ... }:

{
  #> SSH
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    allowSFTP = true;
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };

    #Support legacy ssh-rsa keys
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  #? Note: OpenSSH makes sshd daemon, so we are disabling it on startup as a security measure
  #? Did you read the note above ?
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

}