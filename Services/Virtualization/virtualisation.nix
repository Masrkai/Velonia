{ lib, pkgs, config, ... }:

let
  virtualizationGroups = [ "libvirt" "libvirtd" "kvm" "ubridge" ];
in

{

    # users.groups =
    #   lib.mkIf config.virtualisation.libvirtd.enable
    #     (builtins.listToAttrs (map (g: {
    #       name = g;
    #       value.members = [ config.identity.username ];
    #     }) virtualizationGroups));


users.users.${config.identity.username}.extraGroups = 
  lib.mkIf config.virtualisation.libvirtd.enable
    virtualizationGroups;


    # Rootless podman needs subuid/subgid ranges for your user.
    # (This is per-user; repeat for each account that runs containers.)
    # users.users.${config.identity.username}.subGidRange = 100;
    # also to use this shell.nix on NixOS your user needs to be configured as such:
  # users.extraUsers.adisbladis = {
  #   subUidRanges = [{ startUid = 100000; count = 65536; }];
  #   subGidRanges = [{ startGid = 100000; count = 65536; }];
  # };


    hardware.nvidia-container-toolkit.enable = 
    lib.elem "nvidia" config.services.xserver.videoDrivers;


    virtualisation = {

      podman = {
        enable = true;
        dockerCompat = true;

        # Required for `docker-compose` style networking to resolve names.
        networkSocket.port = 2376;
        networkSocket.openFirewall = false;
        defaultNetwork.settings.dns_enabled = true;
      };

      # oci-containers = {
      #   backend = "podman";
      #   containers = {
      #     "open-webui" = import ./containers/open-webui.nix;
      #   };
      # };

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


        };
      };

    };
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable   = true;
    programs.dconf.enable = true;


    environment.systemPackages = with pkgs; [
      qemu-utils
      virt-viewer
      virt-manager
      spice
      spice-protocol
      virglrenderer  # Required for 3D acceleration

      # Useful extras for CI-style work on the host:
      podman
      podman-tui # status of containers in the terminal
      podman-compose
      buildah    # for rebuilding images from Containerfiles
      skopeo     # copy/inspect images across registries
      dive       # inspect image layers

    ];
}