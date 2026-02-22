{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;

    # NVIDIA host: enable CUDA/NVENC support in OBS encoders.
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };

    # Wayland/Hyprland-focused capture plugins.
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
    ];

    # Virtual camera support via v4l2loopback + polkit.
    enableVirtualCamera = true;
  };
}
