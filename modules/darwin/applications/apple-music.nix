{ config, pkgs, ... }:

{
  # Download Dolby Atmos
  system.defaults.CustomUserPreferences."com.apple.Music".downloadDolbyAtmos = 1;

  # Enable Lossless Audio with ALAC up to 24-bit / 48 kHz
  system.defaults.CustomUserPreferences."com.apple.Music".losslessEnabled = 1;
  system.defaults.CustomUserPreferences."com.apple.Music".preferredDownloadAudioQuality = 15;
  system.defaults.CustomUserPreferences."com.apple.Music".preferredStreamPlaybackAudioQuality = 15;

  # Disable playback notifications
  system.defaults.CustomUserPreferences."com.apple.Music".userWantsPlaybackNotifications = 0;
}
