_: {
  security = {
    pam.services.sudo_local = {
      # Enable Touch ID for sudo authentication
      touchIdAuth = true;

      # Disable Apple Watch for sudo authentication
      watchIdAuth = false;
    };
  };
}
