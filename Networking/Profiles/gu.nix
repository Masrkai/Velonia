{ lib, ... }:

lib.mkMerge [
    {
        networking.networkmanager.ensureProfiles.profiles = {
          "Library" = {
            connection = {
              id = "Library";
              type = "wifi";
              uuid = "0ea68fe5-6bab-4f05-926a-dd90666a75da";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 0;
            };
            wifi = {
              hidden = false;
              ssid = "Study";
              mode = "infrastructure";
              bssid = "A4:B2:39:9C:EC:C0";
              cloned-mac-address = "random";
              generate-mac-address-mask = "FE:FF:FF:00:00:00 00:00:0C:00:00:00";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Study_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };

          "GU-Dorms" = {
            connection = {
              id = "GU-Dorms";
              type = "wifi";
              uuid = "f43ba556-93d8-4b63-b08b-16bc6d2c2f20";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 1;
            };
            wifi = {
              hidden = false;
              ssid = "GU-Dorms";
              mode = "infrastructure";
              cloned-mac-address = "random";
              generate-mac-address-mask = "FE:FF:FF:00:00:00 00:00:0C:00:00:00";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${GU_DORMS_PSK}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };

          "GU-Wifi" = {
            connection = {
              id = "GU-Wifi";
              type = "wifi";
              uuid = "535699d5-fea6-4be2-b5b2-67da5bebb50a";
              permissions = "";
              autoconnect = false;
              # autoconnect-priority = 2 ;
            };
            wifi = {
              hidden = false;
              ssid = "GU-WiFi";
              mode = "infrastructure";
              cloned-mac-address = "random";
              generate-mac-address-mask = "FE:FF:FF:00:00:00 00:00:0C:00:00:00";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
              # dhcp-timeout = 90;           # Increase timeout
              # dhcp-send-hostname = false;  # Some Cisco networks reject hostname
            };
            ipv6 = {
              method = "disabled";
            };
          };

          "Gu_EMP" = {
            connection = {
              type = "wifi";
              id   = "Gu_EMP";
              uuid = "da611e1d-fbc4-4256-98ed-df5e09c7e222";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 1;
            };
            wifi = {
              hidden = false;
              ssid = "Gu_EMP";
              mode = "infrastructure";
              cloned-mac-address = "random";
              generate-mac-address-mask = "FE:FF:FF:00:00:00 00:00:0C:00:00:00";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Gu_EMP_pass}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              # method = "manual";
              # address1 = "172.17.36.201/24,172.17.32.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };

        };

    }

]
