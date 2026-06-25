#!/bin/bash
PORT=${PORT:-8080}
export HOME=/root
export USER=root
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-root
export XDG_SESSION_TYPE=x11
export LIBGL_ALWAYS_SOFTWARE=1

mkdir -p /tmp/runtime-root && chmod 700 /tmp/runtime-root
mkdir -p /root/.cache /root/.local/share

echo "==> Xvfb starting..."
Xvfb :1 -screen 0 1280x720x24 -ac -noreset &
sleep 5
echo "==> dbus starting..."
mkdir -p /run/dbus && rm -f /run/dbus/pid
dbus-daemon --system --fork 2>/dev/null || true
sleep 1
eval $(dbus-launch --sh-syntax 2>/dev/null) || true

xsetroot -display :1 -solid "#0563AE" 2>/dev/null || true

echo "==> XFCE4 starting..."
startxfce4 >/tmp/xfce4.log 2>&1 &
sleep 12

echo "==> x11vnc starting..."
x11vnc -display :1 -nopw -forever -shared -rfbport 5900 -noxdamage -o /tmp/x11vnc.log &
sleep 3

printf "%s" '<!DOCTYPE html><html><head><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=vnc_auto.html?autoconnect=true&reconnect=true&resize=scale"></head><body style="margin:0;background:#000;color:#fff;display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif"><p>Connecting to Desktop...</p></body></html>' > /usr/share/novnc/index.html

echo "==> noVNC on port $PORT..."
exec websockify --web=/usr/share/novnc/ $PORT localhost:5900
