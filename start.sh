#!/bin/bash

  PORT=${PORT:-8080}

  # Virtual display
  Xvfb :1 -screen 0 1280x720x16 &
  sleep 2

  export DISPLAY=:1

  # dbus
  mkdir -p /run/dbus
  dbus-daemon --system --fork 2>/dev/null || true
  sleep 1

  # XFCE4 desktop
  startxfce4 &
  sleep 3

  # VNC server (no password = direct open in browser)
  x11vnc -display :1 -nopw -forever -shared -rfbport 5900 &
  sleep 2

  # noVNC — browser access on PORT
  websockify --web=/usr/share/novnc/ $PORT localhost:5900

  wait
  