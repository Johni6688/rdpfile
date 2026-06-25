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
      nano \
      novnc \
      python3-websockify \
      procps \
      ca-certificates \
      && apt-get clean && rm -rf /var/lib/apt/lists/*

  RUN echo "root:root" | chpasswd

  # Disable logout/shutdown/restart in XFCE4
  RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml

  # Disable session logout options
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xfce4-session" version="1.0">
    <property name="shutdown" type="empty">
      <property name="ShowHibernate" type="bool" value="false"/>
      <property name="ShowSuspend"   type="bool" value="false"/>
      <property name="ShowHybridSleep" type="bool" value="false"/>
      <property name="ShowSwitchUser" type="bool" value="false"/>
      <property name="LockScreen"    type="bool" value="false"/>
      <property name="Logout"        type="bool" value="false"/>
      <property name="ShowLogout"    type="bool" value="false"/>
    </property>
    <property name="general" type="empty">
      <property name="LockCommand" type="string" value=""/>
    </property>
  </channel>
  EOF

  # Disable xfwm4 compositor (faster)
  RUN cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOF'
  <?xml version="1.0" encoding="UTF-8"?>
  <channel name="xfwm4" version="1.0">
    <property name="general" type="empty">
      <property name="use_compositing" type="bool" value="false"/>
    </property>
  </channel>
  EOF

  # Block shutdown/reboot via polkit
  RUN mkdir -p /etc/polkit-1/localauthority/50-local.d && \
      cat > /etc/polkit-1/localauthority/50-local.d/noshutdown.pkla << 'EOF'
  [No Shutdown]
  Identity=unix-user:*
  Action=org.freedesktop.login1.power-off;org.freedesktop.login1.reboot;org.freedesktop.login1.halt;org.freedesktop.login1.suspend;org.freedesktop.login1.hibernate
  ResultAny=no
  ResultInactive=no
  ResultActive=no
  EOF

  COPY start.sh /start.sh
  RUN chmod +x /start.sh

  EXPOSE 8080

  CMD ["/start.sh"]
  