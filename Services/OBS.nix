{ config, lib, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;
in

{
    programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      input-overlay
      # obs-backgroundremoval #! requires ONNX
      obs-pipewire-audio-capture

      # obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

}