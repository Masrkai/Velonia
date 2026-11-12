{
  config,
  lib,
  pkgs,
  ...
}: {
  security.rtkit.enable = true; #? Allow real-time priorities for audio tasks

  # PipeWire Setup - Gaming Optimized
  services.pipewire = {
    enable = true;
    systemWide = false;
    audio.enable = true;

    wireplumber.enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;

    extraConfig = {
      pipewire."92-stability" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [44100 48000 88200 96000];
          "default.clock.quantum" = 2048;
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 4096;
        };
      };

      pipewire-pulse."92-stability" = {
        "stream.properties" = {
          "resample.quality" = 10;
          "node.latency" = "2048/48000";
        };
        "pulse.properties" = {
          "pulse.min.req" = "2048/48000";
          "pulse.default.req" = "2048/48000";
          "pulse.min.frag" = "1024/48000";
          "pulse.min.quantum" = "1024/48000";
          "pulse.max.req" = "8192/48000";
          "pulse.max.quantum" = "8192/48000";
        };
      };
    };
  };

  #--> NoiseTorch: Real-Time Microphone Noise Suppression
  programs.noisetorch.enable = false;

  # OBS Studio Setup
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = false;
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
