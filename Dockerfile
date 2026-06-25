FROM debian:bullseye-slim

  ENV DEBIAN_FRONTEND=noninteractive

  RUN apt-get update && apt-get install -y --no-install-recommends \
      xfce4 \
      xfce4-terminal \
      xfce4-panel \
      xfce4-session \
      xfwm4 \
      xfdesktop4 \
      thunar \
      mousepad \
      ristretto \
      xorg \
      x11vnc \
      xvfb \
      dbus \
      dbus-x11 \
      sudo \
      curl \
      wget \
      git \
      unzip \
      nano \
      novnc \
      python3-websockify \
      procps \
      ca-certificates \
      gtk2-engines-murrine \
      gtk2-engines-pixbuf \
      firefox-esr \
      && apt-get clean && rm -rf /var/lib/apt/lists/*

  RUN echo "root:root" | chpasswd

  # Windows 10 GTK Theme
  RUN mkdir -p /usr/share/themes \
   && git clone --depth=1 https://github.com/B00merang-Project/Windows-10.git /usr/share/themes/Windows-10

  # Windows 10 Icons
  RUN mkdir -p /usr/share/icons \
   && git clone --depth=1 https://github.com/B00merang-Project/Windows-10-Icons.git /usr/share/icons/Windows-10-Icons

  # XFCE4 config folder
  RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml

  # GTK + Icon theme
  RUN printf '%s\n' \
  '<?xml version="1.0" encoding="UTF-8"?>' \
  '<channel name="xsettings" version="1.0">' \
  '  <property name="Net" type="empty">' \
  '    <property name="ThemeName" type="string" value="Windows-10"/>' \
  '    <property name="IconThemeName" type="string" value="Windows-10-Icons"/>' \
  '  </property>' \
  '  <property name="Gtk" type="empty">' \
  '    <property name="FontName" type="string" value="Sans 10"/>' \
  '  </property>' \
  '</channel>' \
  > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

  # Window manager theme
  RUN printf '%s\n' \
  '<?xml version="1.0" encoding="UTF-8"?>' \
  '<channel name="xfwm4" version="1.0">' \
  '  <property name="general" type="empty">' \
  '    <property name="theme" type="string" value="Windows-10"/>' \
  '    <property name="button_layout" type="string" value="O|HMC"/>' \
  '    <property name="use_compositing" type="bool" value="false"/>' \
  '  </property>' \
  '</channel>' \
  > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

  # Blue desktop wallpaper (Windows 10 color)
  RUN printf '%s\n' \
  '<?xml version="1.0" encoding="UTF-8"?>' \
  '<channel name="xfce4-desktop" version="1.0">' \
  '  <property name="backdrop" type="empty">' \
  '    <property name="screen0" type="empty">' \
  '      <property name="monitor0" type="empty">' \
  '        <property name="workspace0" type="empty">' \
  '          <property name="color-style" type="int" value="0"/>' \
  '          <property name="rgba1" type="array">' \
  '            <value type="double" value="0.031"/>' \
  '            <value type="double" value="0.361"/>' \
  '            <value type="double" value="0.710"/>' \
  '            <value type="double" value="1.000"/>' \
  '          </property>' \
  '          <property name="image-style" type="int" value="0"/>' \
  '        </property>' \
  '      </property>' \
  '    </property>' \
  '  </property>' \
  '</channel>' \
  > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

  # Disable logout/shutdown/restart
  RUN printf '%s\n' \
  '<?xml version="1.0" encoding="UTF-8"?>' \
  '<channel name="xfce4-session" version="1.0">' \
  '  <property name="shutdown" type="empty">' \
  '    <property name="ShowHibernate" type="bool" value="false"/>' \
  '    <property name="ShowSuspend" type="bool" value="false"/>' \
  '    <property name="ShowLogout" type="bool" value="false"/>' \
  '    <property name="ShowSwitchUser" type="bool" value="false"/>' \
  '    <property name="LockScreen" type="bool" value="false"/>' \
  '  </property>' \
  '</channel>' \
  > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml

  # Desktop shortcuts
  RUN mkdir -p /root/Desktop

  # Firefox shortcut on Desktop
  RUN printf '%s\n' \
  '[Desktop Entry]' \
  'Version=1.0' \
  'Type=Application' \
  'Name=Firefox Browser' \
  'Exec=firefox-esr' \
  'Icon=firefox-esr' \
  'Terminal=false' \
  'Categories=Network;WebBrowser;' \
  > /root/Desktop/firefox.desktop && chmod +x /root/Desktop/firefox.desktop

  # File Manager shortcut
  RUN printf '%s\n' \
  '[Desktop Entry]' \
  'Version=1.0' \
  'Type=Application' \
  'Name=File Manager' \
  'Exec=thunar' \
  'Icon=system-file-manager' \
  'Terminal=false' \
  'Categories=Utility;FileManager;' \
  > /root/Desktop/files.desktop && chmod +x /root/Desktop/files.desktop

  # Terminal shortcut
  RUN printf '%s\n' \
  '[Desktop Entry]' \
  'Version=1.0' \
  'Type=Application' \
  'Name=Terminal' \
  'Exec=xfce4-terminal' \
  'Icon=utilities-terminal' \
  'Terminal=false' \
  'Categories=Utility;' \
  > /root/Desktop/terminal.desktop && chmod +x /root/Desktop/terminal.desktop

  # Text Editor shortcut
  RUN printf '%s\n' \
  '[Desktop Entry]' \
  'Version=1.0' \
  'Type=Application' \
  'Name=Text Editor' \
  'Exec=mousepad' \
  'Icon=text-editor' \
  'Terminal=false' \
  'Categories=Utility;TextEditor;' \
  > /root/Desktop/editor.desktop && chmod +x /root/Desktop/editor.desktop

  COPY start.sh /start.sh
  RUN chmod +x /start.sh

  EXPOSE 8080

  CMD ["/start.sh"]
  