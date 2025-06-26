{
  ...
}:

{
  # Enable Touch ID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Disable Apple Watch for sudo authentication
  security.pam.services.sudo_local.watchIdAuth = false;
}
