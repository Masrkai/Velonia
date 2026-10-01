{pkgs, ...}:

{
  #> WireGuard
  # Enable WireGuard kernel module
  networking.wireguard.enable = true;

  # Install WireGuard tools for importing/managing configs
  environment.systemPackages = with pkgs; [
    wireguard-tools  # Provides wg, wg-quick commands
  ];

  # # NetworkManager WireGuard plugin for GUI/nmcli management
  # networking.networkmanager.plugins = with pkgs; [
  #   networkmanager-wireguard
  # ];

  # Optional: If you want to define WireGuard interfaces declaratively
  # This is an alternative to importing configs via NetworkManager
  # You can remove this section if you only use NetworkManager
  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     ips = [ "10.100.0.2/24" ];
  #     listenPort = 51820;
  #
  #     privateKeyFile = "/etc/nixos/Sec/wireguard-private.key";
  #
  #     peers = [
  #       {
  #         publicKey = "PEER_PUBLIC_KEY_HERE";
  #         allowedIPs = [ "0.0.0.0/0" ];  # Route all traffic through VPN
  #         endpoint = "vpn.example.com:51820";
  #         persistentKeepalive = 25;
  #       }
  #     ];
  #   };
  # };
}