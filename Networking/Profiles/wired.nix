{ lib, ... }:

lib.mkMerge [
    {
        networking.networkmanager.ensureProfiles.profiles = {
                "Ethernet" = {
                    connection = {
                    id = "Ethernet";
                    type = "ethernet";
                    permissions = "";
                    # interface-name = "eth0";              # Specify the interface name
                    autoconnect = true;
                    permanent = true;  # This makes the profile persistent
                    uuid = "f2e74118-d0c6-367b-8e88-e5b1f3aa6640";

                    };
                    ethernet = {
                      cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                      auto-negotiate =  true;
                    };
                    ipv4 = {
                      method = "auto";         #? Use DHCP for IPv4
                      dns = "127.0.0.1";       #? Local DNS resolver
                      ignore-auto-dns = true;  #? Ignore DNS provided by DHCP
                    };
                    ipv6 = {
                      method = "disabled";      #? Disable IPv6
                    };
                };
                "Configuring Networks" = {
                    connection = {
                    id = "Ethernet 1";
                    type = "ethernet";
                    permissions = "";
                    # interface-name = "eth0";              # Specify the interface name
                    autoconnect = false;
                    permanent = true;  # This makes the profile persistent
                    uuid = "32ddf296-dd33-3d76-845e-27cabbc7dbef";

                    };
                    ethernet = {
                      cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                      auto-negotiate =  true;
                    };
                    ipv4 = {
                      method = "manual";
                      address1 = "192.168.2.10/24,192.168.2.1";  # IP/prefix,gateway
                      dns = "127.0.0.1";         # You can add more DNS servers if needed
                      ignore-auto-dns = true;
                    };
                    ipv6 = {
                      method = "disabled";      #? Disable IPv6
                    };
                };
                "USB" = {
                    connection = {
                    id = "USB";
                    type = "ethernet";
                    permissions = "";
                    interface-name = "usb0";              # Specify the interface name
                    autoconnect = true;
                    permanent = true;  # This makes the profile persistent
                    uuid = "169f886a-a71a-3fec-ad2a-b66c0c53f473";

                    };
                    ethernet = {
                      cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                    };
                    ipv4 = {
                      method = "auto";         #? Use DHCP for IPv4
                      dns = "127.0.0.1";       #? Local DNS resolver
                      ignore-auto-dns = true;  #? Ignore DNS provided by DHCP
                    };
                    ipv6 = {
                      method = "disabled";      #? Disable IPv6
                    };
                };

        };

    }

]