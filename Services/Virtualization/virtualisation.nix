{ lib, pkgs, config, ... }:

let
  virtualizationGroups = [ "libvirt" "libvirtd" "kvm" "ubridge" ];
in

{

    environment.systemPackages = with pkgs; [
      #> Virtualization
      qemu-utils
      virt-viewer
      virt-manager
      spice
      spice-protocol
      virglrenderer  # Required for 3D acceleration
    ];

    users.groups =
      lib.mkIf config.virtualisation.libvirtd.enable
        (builtins.listToAttrs (map (g: {
          name = g;
          value.members = [ config.identity.username ];
        }) virtualizationGroups));

    #--> Qemu KVM & VirtualBox
    virtualisation = lib.mkForce {
    spiceUSBRedirection.enable = true;
      libvirtd = {
        enable = true;
        onBoot = "start";
        allowedBridges = [ "virbr0"];

        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;

          vhostUserPackages = with pkgs; [
            win-spice
            virtiofsd
            virtio-win
            virglrenderer
          ];

          # verbatimConfig = ''
          # cgroup_device_acl = [
          #   "/dev/null", "/dev/full", "/dev/zero",
          #   "/dev/random", "/dev/urandom", "/dev/ptmx",
          #   "/dev/kvm", "/dev/dri/renderD128"
          # ]
          # nvram = [ "${pkgs.OVMFFull}/FV/OVMF.fd:${pkgs.OVMFFull}/FV/OVMF_VARS.fd" ]
          # '';

          # ovmf = {
          #   enable = true;
          #   packages = [(pkgs.OVMFFull.override {
          #   secureBoot = true;
          #   tpmSupport = true;
          # }).fd];
          # };
        };
      };

    };
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable   = true;
    programs.dconf.enable = true;


}