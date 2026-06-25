#!/bin/bash
  set -e

  PORT=${PORT:-8080}

  echo "==> Starting Xvfb..."
  Xvfb :1 -screen 0 1280x720x16 -ac +extension GLX +render -noreset &
  sleep 4

  export DISPLAY=:1
  export HOME=/root

  echo "==> Starting dbus..."
  mkdir -p /run/dbus /var/run/dbus
  rm -f /run/dbus/pid /var/run/dbus/pid
  dbus-daemon --system --fork 2>/dev/null || true
  sleep 1

  eval $(dbus-launch --sh-syntax --exit-with-session) 2>/dev/null || true

  echo "==> Starting XFCE4..."
  xfce4-session &
  sleep 5

  echo "==> Starting x11vnc..."
  x11vnc -display :1 -nopw -forever -shared \
         -rfbport 5900 -bg -noxdamage \
         -o /tmp/x11vnc.log 2>/dev/null || true
  sleep 2

  echo "==> Starting noVNC on port $PORT..."
  websockify --web=/usr/share/novnc/ $PORT localhost:5900

  wait
  