# SSI - Secret Service Integration, using keePassXC because KDE_wallet implementation is horrible it costed me a rollback checkup 2 times (even tho i was ready i am not risking it)

{ config, pkgs, lib, ... }:

let
  keepassxcSecretService = pkgs.runCommand "keepassxc-secret-service" {} ''
    mkdir -p $out/share/dbus-1/services
    cat > $out/share/dbus-1/services/org.freedesktop.secrets.service << EOF
    [D-BUS Service]
    Name=org.freedesktop.secrets
    Exec=${pkgs.keepassxc}/bin/keepassxc
    EOF
  '';

#   disableKwalletCompat = pkgs.runCommand "disable-kwallet-compat" {} ''
#     mkdir -p $out/share/dbus-1/services
#     cat > $out/share/dbus-1/services/org.kde.secretservicecompat.service << EOF
#     [D-BUS Service]
#     Name=org.kde.secretservicecompat
#     Exec=/bin/false
#     EOF
#   '';
in
{
  config = lib.mkIf config.hardware.isAsusTuf {
    environment.systemPackages = with pkgs; [
       keepassxc
       libsecret
    ];

    security.pam.services.login.kwallet.enable = lib.mkDefault false;
    security.pam.services.sddm.kwallet.enable  = lib.mkDefault false;

    services.dbus.packages = [ 
      keepassxcSecretService
      #  disableKwalletCompat
        ];

    environment.etc."xdg/autostart/keepassxc.desktop".text = ''
      [Desktop Entry]
      Name=KeePassXC
      Exec=${pkgs.keepassxc}/bin/keepassxc
      Type=Application
      X-GNOME-Autostart-enabled=true
    '';
  };
}

#? Store a dummy secret (It will prompt you to type a password)
#> secret-tool store --label="test-secret" service "mytest" username "testuser"

#? Retrieve it back
#> secret-tool lookup service "mytest" username "testuser"

#? # List all secrets visible via secret service
#> secret-tool search --all service "mytest"

#? What to watch for:
#? Store: KeePassXC should pop up asking you to confirm saving the secret into its database (it'll ask which group)
#? Lookup: should return your password without any GUI appearing
#? If DB is locked: KeePassXC will prompt for your master password first, then serve the secret