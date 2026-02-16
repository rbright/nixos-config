_: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "application/x-gnome-saved-search" = [ "thunar.desktop" ];
      "x-scheme-handler/file" = [ "thunar.desktop" ];
    };
  };

  # Thunar may rewrite this file, so force replacement to avoid backup
  # collisions with pre-existing *.hm-backup files during activation.
  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml" = {
    force = true;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>

      <channel name="thunar" version="1.0">
        <property name="last-view" type="string" value="ThunarDetailsView"/>
      </channel>
    '';
  };
}
