{ lib, pkgs, config, ... }:

let
  virtualizationGroups = [ "libvirt" "libvirtd" "kvm" "ubridge" ];
in

{

    users.groups =
      lib.mkIf config.virtualisation.libvirtd.enable
        (builtins.listToAttrs (map (g: {
          name = g;
          value.members = [ config.identity.username ];
        }) virtualizationGroups));

    # Rootless podman needs subuid/subgid ranges for your user.
    # (This is per-user; repeat for each account that runs containers.)
    users.users.${config.identity.username}.subUidGidRange = 100;


    #--> Qemu KVM & VirtualBox
    virtualisation = lib.mkForce {


      podman = {
        enable = false;
        dockerCompat = true;
        #defaultNetwork.settings.dns_enabled = true;

        # Required for `docker-compose` style networking to resolve names.
        defaultNetwork.settings.dns_enabled = true;

        # Pull from Docker Hub / ghcr.io by default.
        registries.search = [ "docker.io" "ghcr.io" "quay.io" ];
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
      podman-compose
      buildah    # for rebuilding images from Containerfiles
      skopeo     # copy/inspect images across registries
      dive       # inspect image layers
    ];
}