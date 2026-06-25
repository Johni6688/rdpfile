FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4-session xfwm4 xfce4-panel xfdesktop4 \
    xfce4-terminal thunar mousepad \
    xorg x11vnc xvfb \
    dbus dbus-x11 \
    wget curl git nano \
    novnc python3-websockify \
    procps ca-certificates \
    gtk2-engines-murrine gtk2-engines-pixbuf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "root:root" | chpasswd

RUN git clone --depth=1 https://github.com/B00merang-Project/Windows-10.git /usr/share/themes/Windows-10
RUN git clone --depth=1 https://github.com/B00merang-Project/Windows-10-Icons.git /usr/share/icons/Windows-10-Icons

RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml /root/Desktop

RUN printf '<?xml version="1.0" encoding="UTF-8"?>\n<channel name="xsettings" version="1.0">\n<property name="Net" type="empty">\n<property name="ThemeName" type="string" value="Windows-10"/>\n<property name="IconThemeName" type="string" value="Windows-10-Icons"/>\n</property>\n</channel>\n' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
RUN printf '<?xml version="1.0" encoding="UTF-8"?>\n<channel name="xfwm4" version="1.0">\n<property name="general" type="empty">\n<property name="theme" type="string" value="Windows-10"/>\n<property name="button_layout" type="string" value="O|HMC"/>\n<property name="use_compositing" type="bool" value="false"/>\n</property>\n</channel>\n' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
RUN printf '<?xml version="1.0" encoding="UTF-8"?>\n<channel name="xfce4-session" version="1.0">\n<property name="shutdown" type="empty">\n<property name="ShowHibernate" type="bool" value="false"/>\n<property name="ShowSuspend" type="bool" value="false"/>\n<property name="ShowLogout" type="bool" value="false"/>\n<property name="ShowSwitchUser" type="bool" value="false"/>\n<property name="LockScreen" type="bool" value="false"/>\n</property>\n</channel>\n' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml

RUN printf "[Desktop Entry]\nType=Application\nName=Files\nExec=thunar\nIcon=system-file-manager\nTerminal=false\n" > /root/Desktop/files.desktop && chmod +x /root/Desktop/files.desktop
RUN printf "[Desktop Entry]\nType=Application\nName=Terminal\nExec=xfce4-terminal\nIcon=utilities-terminal\nTerminal=false\n" > /root/Desktop/terminal.desktop && chmod +x /root/Desktop/terminal.desktop
RUN printf "[Desktop Entry]\nType=Application\nName=Text Editor\nExec=mousepad\nIcon=accessories-text-editor\nTerminal=false\n" > /root/Desktop/editor.desktop && chmod +x /root/Desktop/editor.desktop

COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 8080
CMD ["/start.sh"]
