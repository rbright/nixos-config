{ user, ... }:
{
  system.activationScripts.postActivation.text = ''
    # Avoid logout/login cycle to apply settings.
    sudo -u ${user} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
