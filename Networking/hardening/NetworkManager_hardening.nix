{ config, lib, pkgs, modulesPath, ... }:

{

    systemd.services.NetworkManager = {
      serviceConfig = {
        # Isolation fundamentals - creating a secure execution environment
        RuntimeDirectory = "NetworkManager";
        RuntimeDirectoryMode = "0755";

        PrivateTmp = true;
        ProtectHome = false;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "+/run/NetworkManager/"
          "/proc/sys/net/"
          "/etc/machine-id"
          "/etc/resolv.conf"
          "/etc/NetworkManager/"

          "+/var/lib/dhcpcd/"
          "+/var/lib/NetworkManager/"
        ];

        # Enhanced process isolation
        ProtectClock = true;
        ProtectHostname = true;
        LockPersonality = true;
        ProcSubset = "all";
        ProtectProc = "ptraceable";

        # Device and kernel protection layers
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true;

        PrivateDevices = false;

        CapabilityBoundingSet = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
          "CAP_SYS_MODULE"
          "CAP_AUDIT_WRITE"
          "CAP_NET_BIND_SERVICE"
        ];

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_PACKET"
          "AF_NETLINK"
          "AF_BLUETOOTH"
        ];

        SystemCallFilter = [
          "@process"
          "@network-io"
          "@privileged"
          "@file-system"
          "@system-service"
          "~@swap"
          "~@clock"
          "~@debug"
          "~@mount"
          "~@raw-io"
          "~@reboot"
          "~@obsolete"
          "~@resources"
          "~@cpu-emulation"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        # Fixed: Use boolean or space-separated list, not ~ prefixes
        # RestrictNamespaces = false;  # Allow all namespaces for NetworkManager
        # OR to be more restrictive:
        RestrictNamespaces = "net pid";  # Only allow net and pid namespaces

        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        UMask = "0027";
      };
    };
}