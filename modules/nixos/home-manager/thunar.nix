_: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "application/x-gnome-saved-search" = [ "thunar.desktop" ];
      "x-scheme-handler/file" = [ "thunar.desktop" ];
    };
  };

  # Avoid runtime xfconf activation failures by writing the channel file directly.
  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>

    <channel name="thunar" version="1.0">
      <property name="last-view" type="string" value="ThunarDetailsView"/>
    </channel>
  '';
}
