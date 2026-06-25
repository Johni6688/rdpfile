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

echo "==> Xvfb 1024x768x16..."
Xvfb :1 -screen 0 1024x768x16 -ac -noreset &
sleep 4

mkdir -p /run/dbus && rm -f /run/dbus/pid
dbus-daemon --system --fork 2>/dev/null || true
sleep 1
eval $(dbus-launch --sh-syntax 2>/dev/null) || true

xsetroot -display :1 -solid "#0563AE" 2>/dev/null || true

echo "==> XFCE4 starting..."
startxfce4 >/tmp/xfce4.log 2>&1 &
sleep 10

echo "==> x11vnc starting..."
x11vnc -display :1 -nopw -forever -shared \
  -rfbport 5900 -noxdamage \
  -compress 6 -quality 6 \
  -o /tmp/x11vnc.log &
sleep 3

# Replace vnc_auto.html with fullscreen auto-connect page
python3 -c "
import urllib.request, base64, os
html = open('/usr/share/novnc/vnc_auto.html').read() if os.path.exists('/usr/share/novnc/vnc_auto.html') else ''
" 2>/dev/null || true

# Simple redirect to vnc_auto with scale
printf '%s' '<!DOCTYPE html><html><head><meta charset="utf-8"><style>*{margin:0;padding:0}html,body{width:100%;height:100%;background:#0563AE;overflow:hidden}iframe{width:100vw;height:100vh;border:none;display:block}</style></head><body><iframe src="vnc_auto.html?autoconnect=true&reconnect=true&reconnect_delay=2000&resize=scale&quality=6&compression=6" allowfullscreen></iframe></body></html>' > /usr/share/novnc/index.html

echo "==> noVNC on port $PORT..."
exec websockify --web=/usr/share/novnc/ $PORT localhost:5900
