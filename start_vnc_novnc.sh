#!/bin/bash
# Start VNC Server and noVNC Proxy for remote access

echo "🖥️  Iniciando VNC Server..."

# Kill any existing VNC processes
pkill -9 Xtightvnc Xvfb 2>/dev/null || true

# Create .vnc directory if it doesn't exist
mkdir -p ~/.vnc

# Set VNC password (default: hermes123)
echo "hermes123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start Xvfb (virtual framebuffer) with resolution 1280x720
Xvfb :1 -screen 0 1280x720x24 &
XVFB_PID=$!
echo "✅ Xvfb started (PID: $XVFB_PID)"

# Wait for Xvfb to start
sleep 2

# Start TightVNCServer
export DISPLAY=:1
tightvncserver :1 -geometry 1280x720 -depth 24 -nolisten tcp 2>/dev/null &
VNC_PID=$!
echo "✅ VNC Server started on port 5901 (PID: $VNC_PID)"
echo "   Password: hermes123"

# Wait for VNC to start
sleep 3

# Start noVNC proxy
echo "🌐 Iniciando noVNC proxy en puerto 6080..."
cd ~/noVNC
./utils/novnc_proxy --vnc localhost:5901 --listen 6080 2>&1 | while read line; do
    echo "[noVNC] $line"
done &
NOVNC_PID=$!
echo "✅ noVNC proxy started (PID: $NOVNC_PID)"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              🖥️  VNC & noVNC Setup Completado             ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║ Acceso remoto disponible en:                             ║"
echo "║ 🌐 http://localhost:6080/vnc.html                         ║"
echo "║                                                            ║"
echo "║ Contraseña VNC: hermes123                                  ║"
echo "║                                                            ║"
echo "║ PIDs:                                                      ║"
echo "║   - Xvfb: $XVFB_PID"
echo "║   - VNC:  $VNC_PID"
echo "║   - noVNC: $NOVNC_PID"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Keep the script running
wait
