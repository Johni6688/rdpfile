FROM debian:bullseye-slim

  ENV DEBIAN_FRONTEND=noninteractive

  RUN apt-get update && apt-get install -y --no-install-recommends \
      xfce4 \
      xfce4-terminal \
      xfce4-panel \
      xfce4-session \
      xfwm4 \
      xfdesktop4 \
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
      sassc \
      && apt-get clean && rm -rf /var/lib/apt/lists/*

  RUN echo "root:root" | chpasswd

  # === Windows 10 Theme ===
  RUN mkdir -p /usr/share/themes && \
      cd /tmp && \
      git clone --depth=1 https://github.com/B00merang-Project/Windows-10.git && \
      cp -r Windows-10 /usr/share/themes/Windows-10 && \
      rm -rf /tmp/Windows-10

  # === Windows 10 Icons ===
  RUN mkdir -p /usr/share/icons && \
      cd /tmp && \
      git clone --depth=1 https://github.com/B00merang-Project/Windows-10-Icons.git && \
      cp -r Windows-10-Icons /usr/share/icons/Windows-10-Icons && \
      rm -rf /tmp/Windows-10-Icons

  # === XFCE4 Config — Windows 10 Look ===
  RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml

  # GTK theme
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xsettings" version="1.0">
    <property name="Net" type="empty">
      <property name="ThemeName"  type="string" value="Windows-10"/>
      <property name="IconThemeName" type="string" value="Windows-10-Icons"/>
      <property name="EnableEventSounds" type="bool" value="false"/>
    </property>
    <property name="Gtk" type="empty">
      <property name="FontName" type="string" value="Segoe UI 10"/>
      <property name="MonospaceFontName" type="string" value="Consolas 11"/>
      <property name="CursorThemeName" type="string" value="default"/>
    </property>
  </channel>
  EOF

  # Window manager theme
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xfwm4" version="1.0">
    <property name="general" type="empty">
      <property name="theme"            type="string" value="Windows-10"/>
      <property name="title_font"       type="string" value="Segoe UI Bold 9"/>
      <property name="button_layout"    type="string" value="O|HMC"/>
      <property name="use_compositing"  type="bool"   value="false"/>
    </property>
  </channel>
  EOF

  # Desktop wallpaper (blue like Win10)
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xfce4-desktop" version="1.0">
    <property name="backdrop" type="empty">
      <property name="screen0" type="empty">
        <property name="monitor0" type="empty">
          <property name="workspace0" type="empty">
            <property name="color-style"    type="int"  value="0"/>
            <property name="rgba1"          type="array">
              <value type="double" value="0.031"/>
              <value type="double" value="0.361"/>
              <value type="double" value="0.710"/>
              <value type="double" value="1.000"/>
            </property>
            <property name="image-style"    type="int"  value="0"/>
          </property>
        </property>
      </property>
    </property>
  </channel>
  EOF

  # Panel — Windows 10 Taskbar style (bottom)
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xfce4-panel" version="1.0">
    <property name="configver" type="int" value="2"/>
    <property name="panels" type="array">
      <value type="int" value="1"/>
    </property>
    <property name="panel-1" type="empty">
      <property name="position"       type="string" value="p=8;x=0;y=0"/>
      <property name="length"         type="uint"   value="100"/>
      <property name="position-locked" type="bool"  value="true"/>
      <property name="size"           type="uint"   value="38"/>
      <property name="plugin-ids"     type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
      </property>
    </property>
    <property name="plugins" type="empty">
      <property name="plugin-1" type="string" value="applicationsmenu"/>
      <property name="plugin-2" type="string" value="tasklist"/>
      <property name="plugin-3" type="string" value="separator">
        <property name="expand" type="bool" value="true"/>
        <property name="style"  type="uint" value="0"/>
      </property>
      <property name="plugin-4" type="string" value="clock"/>
    </property>
  </channel>
  EOF

  # Disable logout/shutdown
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xfce4-session" version="1.0">
    <property name="shutdown" type="empty">
      <property name="ShowHibernate"   type="bool" value="false"/>
      <property name="ShowSuspend"     type="bool" value="false"/>
      <property name="ShowLogout"      type="bool" value="false"/>
      <property name="ShowSwitchUser"  type="bool" value="false"/>
      <property name="LockScreen"      type="bool" value="false"/>
    </property>
  </channel>
  EOF

  COPY start.sh /start.sh
  RUN chmod +x /start.sh

  EXPOSE 8080

  CMD ["/start.sh"]
  