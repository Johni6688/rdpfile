#!/bin/bash

  PORT=${PORT:-8080}

  export HOME=/root
  export USER=root
  export DISPLAY=:1
  export XDG_RUNTIME_DIR=/tmp/runtime-root
  export XDG_SESSION_TYPE=x11

  mkdir -p /tmp/runtime-root
  chmod 700 /tmp/runtime-root

  echo "==> Starting Xvfb (1024x768)..."
  Xvfb :1 -screen 0 1024x768x16 -ac -noreset &
  sleep 3

  echo "==> Starting dbus..."
  mkdir -p /run/dbus
  rm -f /run/dbus/pid
  dbus-daemon --system --fork 2>/dev/null || true
  sleep 1

  export $(dbus-launch --sh-syntax 2>/dev/null) || true

  echo "==> Starting XFCE4..."
  startxfce4 &
  sleep 6

  echo "==> Starting x11vnc..."
  x11vnc -display :1 -nopw -forever -shared \
         -rfbport 5900 -noxdamage -bg \
         -o /tmp/x11vnc.log
  sleep 2

  # Auto-redirect root URL to desktop
  echo '<html><head><meta http-equiv="refresh" content="0; url=vnc_auto.html"></head><body>Loading desktop...</body></html>' > /usr/share/novnc/index.html

  echo "==> noVNC on port $PORT..."
  websockify --web=/usr/share/novnc/ $PORT localhost:5900

  wait
  