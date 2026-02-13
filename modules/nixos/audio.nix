_: {
  # Allow real-time scheduling for low-latency audio workloads.
  security.rtkit.enable = true;

  services = {
    # PipeWire is the primary audio server stack on this host profile.
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };

    # Disable the legacy PulseAudio service when PipeWire is active.
    pulseaudio.enable = false;
  };
}
