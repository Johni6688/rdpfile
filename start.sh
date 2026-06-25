#!/bin/bash

  PORT=${PORT:-8080}

  export HOME=/root
  export USER=root
  export DISPLAY=:1
  export XDG_RUNTIME_DIR=/tmp/runtime-root
  export XDG_SESSION_TYPE=x11
  export LIBGL_ALWAYS_SOFTWARE=1
  export XFCE_PANEL_MIGRATE_DEFAULT=1

  mkdir -p /tmp/runtime-root
  chmod 700 /tmp/runtime-root
  mkdir -p /root/.cache /root/.local/share

  echo "==> Starting Xvfb..."
  Xvfb :1 -screen 0 1280x720x24 -ac -noreset +extension GLX +extension RANDR &
  XVFB_PID=$!
  sleep 4

  # Check Xvfb started
  if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "ERROR: Xvfb failed to start!"
    exit 1
  fi
  echo "Xvfb OK"

  echo "==> Starting dbus..."
  mkdir -p /run/dbus
  rm -f /run/dbus/pid
  dbus-daemon --system --fork 2>/dev/null || true
  sleep 1
  eval $(dbus-launch --sh-syntax 2>/dev/null) || true
  export DBUS_SESSION_BUS_ADDRESS

  echo "==> Setting desktop background..."
  xsetroot -display :1 -solid "#0563AE" 2>/dev/null || true

  echo "==> Starting XFCE4..."
  startxfce4 > /tmp/xfce4.log 2>&1 &
  sleep 10

  # If XFCE4 failed, try basic window manager
  if ! pgrep -x xfwm4 > /dev/null; then
    echo "xfwm4 not running, trying openbox fallback..."
    openbox --display :1 &
    sleep 3
  fi

  echo "==> Starting x11vnc..."
  x11vnc -display :1 -nopw -forever -shared \
         -rfbport 5900 -noxdamage \
         -o /tmp/x11vnc.log &
  sleep 3

  echo "==> Setting fullscreen redirect..."
  cat > /usr/share/novnc/index.html << 'HTMLEOF'
  <!DOCTYPE html>
  <html>
  <head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=vnc_auto.html?autoconnect=true&reconnect=true&resize=scale">
  <style>
    body { margin:0; background:#000; display:flex; justify-content:center; align-items:center; height:100vh; }
    p { color:#fff; font-family:sans-serif; font-size:20px; }
  </style>
  </head>
  <body><p>Connecting to Desktop...</p></body>
  </html>
  HTMLEOF

  echo "==> noVNC on port $PORT..."
  exec websockify --web=/usr/share/novnc/ $PORT localhost:5900
  