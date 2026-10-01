{ lib, pkgs, ... }:

with lib;
{
  # Kernel and boot security configurations
  boot.kernel.sysctl = {
    # Core kernel security settings
    "kernel.dmesg_restrict" = mkForce 1;
    "fs.suid_dumpable" = mkOverride 500 0;
    "kernel.ftrace_enabled" = mkDefault false;
  };

  # Console log level configuration
  boot.consoleLogLevel = mkOverride 500 3;

  # Blacklisted kernel modules
  boot.blacklistedKernelModules = mkForce [
    # Flatpak
    "flatpak"

    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Legacy/rare filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  # Service configurations
  # Disable CUPS
  services.printing.enable = mkForce false;

  # Configure firmware updates
  services.fwupd = {
    enable = true;
    uefiCapsuleSettings = {
      DisableQuiet = true;
      DisableUefiReboot = true;
    };
  };

  # Disable the automatic fwupd refresh service and timer
  # to avoid "Failed to obtain auth" errors when polkit is unavailable
  # see https://github.com/nixos/nixpkgs/issues/530906
  systemd.services.fwupd-refresh.enable = false;
  systemd.timers.fwupd-refresh.enable = false;

  # Disable KWallet PAM integration
  security.pam.services.sddm.kwallet.enable = false;

  # ClamAV configuration
  services.clamav = {
    scanner.enable = false;
    daemon.enable = false;
    updater = {
      enable = false;
      interval = "daily";
      settings = {
        # Enable multithreading
        MaxThreads = 4;  # Adjust based on CPU cores

        # Debug and logging
        LogFile = "/var/log/clamav/clamd.log";
        LogTime = true;
        LogClean = false;
        LogVerbose = false;
      };
    };
    fangfrisch = {
      enable = false;
      interval = "weekly";
    };
  };

  # Package configurations
  environment.systemPackages = with pkgs; [
    clamtk
  ];
}
