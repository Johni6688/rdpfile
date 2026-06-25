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

  COPY start.sh /start.sh
  RUN chmod +x /start.sh

  EXPOSE 8080

  CMD ["/start.sh"]
  