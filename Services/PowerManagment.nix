# PowerManagement.nix
{ lib, config, pkgs, ... }:

{
  imports = [
  ];

    # Enable power-profiles-daemon for ASUS TUF laptops
    services.power-profiles-daemon = {
      enable = true;
    };

    #--> Better scheduling for better CPU cycles & audio performance
    services.system76-scheduler = {
      enable = true;
    };

    services.supergfxd.enable = false;

    services.asusd = lib.mkIf config.hardware.isAsusTuf {
      enable = true;
      # enableUserService = true;
    };

    systemd.services.asusd = lib.mkIf config.services.asusd.enable {
      environment.RUST_LOG = "asusd=warn";
    };

    # # TLP configuration (disabled when power-profiles-daemon is active)
    # services.tlp = {
    #   enable =  config.hardware.isDellG15 ;

    #   settings = {
    #     # AC power settings
    #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
    #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

    #     # Battery power settings
    #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    #     # Additional power saving
    #     WIFI_PWR_ON_BAT = "on";
    #   };
    # };

    # # User-level services (run in the user's session, with display access)
    # systemd.user.services.refresh-rate-battery = lib.mkIf config.hardware.isAsusTuf {
    #   description = "Set 60Hz on battery";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     ExecStart = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-1.mode.1920x1080@60";
    #   };
    # };

    # systemd.user.services.refresh-rate-ac = lib.mkIf config.hardware.isAsusTuf {
    #   description = "Set 144Hz on AC";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     ExecStart = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-1.mode.1920x1080@144";
    #   };
    # };

    # when testing a new rule you can instead of rebooting or re-log in:
    # sudo udevadm control --reload-rules && sudo udevadm trigger
    # services.udev.extraRules = lib.mkIf config.hardware.isAsusTuf ''
    # SUBSYSTEM=="power_supply", DEVPATH=="*/power_supply/ACAD", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --user --machine=masrkai@.host start refresh-rate-battery"
    # SUBSYSTEM=="power_supply", DEVPATH=="*/power_supply/ACAD", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --user --machine=masrkai@.host start refresh-rate-ac"

    # SUBSYSTEM=="power_supply", DEVPATH=="*/power_supply/ACAD", ATTR{online}=="1", RUN+="/bin/sh -c 'echo -1 > /sys/module/usbcore/parameters/autosuspend'"
    # SUBSYSTEM=="power_supply", DEVPATH=="*/power_supply/ACAD", ATTR{online}=="0", RUN+="/bin/sh -c 'echo 2 > /sys/module/usbcore/parameters/autosuspend'"
    # '';
}
