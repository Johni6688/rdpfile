FROM debian:bullseye

  ENV DEBIAN_FRONTEND=noninteractive

  RUN apt-get update && apt-get install -y --no-install-recommends       xfce4       xfce4-terminal       xorg       x11vnc       xvfb       dbus-x11       sudo       curl       wget       nano       firefox-esr       novnc       python3-websockify       procps       ca-certificates       && apt-get clean && rm -rf /var/lib/apt/lists/*

  RUN echo "root:root" | chpasswd
  RUN useradd -m -s /bin/bash user && echo "user:user" | chpasswd && usermod -aG sudo user

  COPY start.sh /start.sh
  RUN chmod +x /start.sh

  EXPOSE 8080

  CMD ["/start.sh"]
  