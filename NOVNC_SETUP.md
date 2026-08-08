# noVNC - Acceso Remoto vía Navegador Web

Accede a tu Hermes Bot + DeepSeek desde cualquier navegador web, sin instalar software.

## 🚀 Quick Start (1 minuto)

### Opción 1: Usando el script automático

```bash
cd ~/jhonn-portfolio
./start_vnc_novnc.sh
```

Luego abre en tu navegador:
```
http://localhost:6080/vnc.html
```

**Contraseña:** `hermes123`

---

## 📋 Requisitos Instalados

✅ VNC Server (tightvncserver)
✅ Xvfb (virtual framebuffer)
✅ noVNC (proxy HTTP/WebSocket)
✅ X11 utilities

---

## 🔧 Instalación Manual

### 1. Iniciar Xvfb (escritorio virtual)

```bash
Xvfb :1 -screen 0 1280x720x24 &
```

### 2. Iniciar VNC Server

```bash
export DISPLAY=:1
tightvncserver :1 -geometry 1280x720 -depth 24
```

### 3. Iniciar noVNC Proxy

```bash
cd ~/noVNC
./utils/novnc_proxy --vnc localhost:5901 --listen 6080
```

---

## 🌐 Acceso desde el Navegador

**URL Local:**
```
http://localhost:6080/vnc.html
```

**URL Remota (si está en un servidor):**
```
http://<IP-del-servidor>:6080/vnc.html
```

**Contraseña predeterminada:**
```
hermes123
```

---

## 🎯 Puertos Utilizados

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| VNC Server | 5901 | Conexión nativa VNC |
| noVNC Proxy | 6080 | Acceso HTTP/WebSocket |
| Telegram Bot | 8080 | Keep-alive server |

---

## 💡 Casos de Uso

### Caso 1: Monitoreo Local
```bash
# En tu máquina local
http://localhost:6080/vnc.html
```

### Caso 2: Acceso Remoto (Codespaces)
GitHub Codespaces proporciona un URL público, así que puedes acceder como:
```
https://tu-codespace.githubpreview.dev:6080/vnc.html
```

### Caso 3: Acceso desde Móvil
Los clientes VNC WebSocket funcionan en móviles moderno:
- Chrome/Firefox en Android
- Safari en iPad
- Navegadores modernos

---

## 🔒 Seguridad

### Aumentar Seguridad

1. **Cambiar contraseña VNC:**
   ```bash
   vncpasswd ~/.vnc/passwd
   ```

2. **Usar HTTPS:**
   ```bash
   ./utils/novnc_proxy --vnc localhost:5901 --listen 6080 \
     --cert /path/to/cert.pem --key /path/to/key.pem
   ```

3. **Restringir acceso (firewall):**
   ```bash
   sudo ufw allow 6080/tcp
   sudo ufw deny 5901/tcp  # Bloquear acceso directo VNC
   ```

---

## 🛠️ Troubleshooting

### "Cannot connect to VNC server"
```bash
# Verifica que VNC esté corriendo
ps aux | grep vnc

# Inicia nuevamente
pkill -9 Xtightvnc
./start_vnc_novnc.sh
```

### "Port 6080 already in use"
```bash
# Encuentra qué proceso usa el puerto
lsof -i :6080

# Mata el proceso
kill -9 <PID>
```

### "Black screen en noVNC"
```bash
# Reinicia Xvfb y VNC
pkill -9 Xvfb Xtightvnc
./start_vnc_novnc.sh
```

### "Contraseña no funciona"
```bash
# Resetea la contraseña
rm ~/.vnc/passwd
echo "tu_nueva_contraseña" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
```

---

## 📊 Arquitectura

```
┌─────────────────────────────────────────────┐
│        Navegador Web (tu máquina)           │
│   http://localhost:6080/vnc.html            │
└────────────────┬────────────────────────────┘
                 │ WebSocket/HTTP
                 │
┌─────────────────────────────────────────────┐
│   noVNC Proxy (puerto 6080)                 │
│   ~/noVNC/utils/novnc_proxy                 │
└────────────────┬────────────────────────────┘
                 │ VNC Protocol
                 │
┌─────────────────────────────────────────────┐
│   VNC Server (puerto 5901)                  │
│   tightvncserver :1                         │
└────────────────┬────────────────────────────┘
                 │ X11
                 │
┌─────────────────────────────────────────────┐
│   Xvfb (Escritorio Virtual)                │
│   Xvfb :1 -screen 0 1280x720x24            │
└─────────────────────────────────────────────┘
```

---

## 🚀 Próximos Pasos

### 1. Iniciar todo junto
```bash
# Terminal 1: Bot de Telegram
source venv/bin/activate
export TELEGRAM_BOT_TOKEN=tu_token
export DEEPSEK_API_KEY=tu_api_key
python3 hermes_telegram_bot.py

# Terminal 2: noVNC
./start_vnc_novnc.sh
```

### 2. Acceder desde navegador
```
http://localhost:6080/vnc.html
```

### 3. Controlar el bot remotamente
- Verás la terminal con el bot corriendo
- Puedes ver logs en tiempo real
- Puedes interactuar con la terminal

---

## 📝 Comandos Útiles

```bash
# Ver procesos VNC/noVNC
ps aux | grep -E "vnc|noVNC|Xvfb"

# Matar todos los procesos VNC
pkill -9 -E "Xtightvnc|Xvfb|novnc_proxy"

# Ver logs de noVNC
tail -f ~/noVNC/novnc.log

# Cambiar resolución
pkill -9 Xvfb
Xvfb :1 -screen 0 1920x1080x24 &

# Cambiar puerto noVNC
./utils/novnc_proxy --vnc localhost:5901 --listen 7777
```

---

## 💬 Integración con Telegram Bot

El bot de Telegram está corriendo en paralelo:
- **Keep-alive server:** Puerto 8080
- **Bot:** Conectado a DeepSeek v4
- **noVNC:** Puerto 6080

Puedes:
1. Enviar mensajes al bot por Telegram
2. Ver la respuesta de DeepSeek en tiempo real vía noVNC
3. Monitorear todo desde un navegador web

---

**¡Listo! Disfruta del acceso remoto sin instalar clientes VNC.** 🎉
