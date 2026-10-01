

{
  security.rtkit.enable = true;         #? Allow real-time priorities for audio tasks

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
        # Main PipeWire configuration
        pipewire = {
          context.properties = {
            # Increased buffer sizes for stability
            default.clock.quantum       = 2048;    # Was 1024
            default.clock.min-quantum   = 1024;    # Minimum safety buffer
            default.clock.max-quantum   = 4096;    # Allow larger buffers when needed

            # Additional stability settings
            default.clock.rate          = 48000;
            default.clock.allowed-rates = [ 44100 48000 88200 96000 ];
          };
        };

        # PulseAudio compatibility layer
        pipewire-pulse = {
          context.properties = {
            # Higher priority for audio thread
            default.clock.quantum       = 2048;
            default.clock.min-quantum   = 1024;
          };

          stream.properties = {
            # High quality resampling
            resample.quality = 10;
            # Prevent audio drops during high load
            node.latency = "2048/48000";
          };

          pulse.properties = {
            # Larger PulseAudio buffers
            pulse.min.req          = "2048/48000";  # Was 1024
            pulse.default.req      = "2048/48000";  # Was 1024
            pulse.min.frag         = "1024/48000";  # Was 256
            pulse.min.quantum      = "1024/48000";  # Was 256

            # Additional buffering for stability
            pulse.max.req          = "8192/48000";
            pulse.max.quantum      = "8192/48000";
          };
        };

      };
  };
}