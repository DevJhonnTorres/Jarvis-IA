# Hermes Telegram Bot - Setup 24/7

Bot de Telegram que ejecuta Hermes Agent de forma continua sin intervención manual.

## Opción 1: Railway (Recomendado - Gratuito)

**Railway** es la forma más fácil y rápida (5 minutos).

### Pasos:

1. **Crear bot en Telegram:**
   - Abre Telegram y busca `@BotFather`
   - Escribe `/newbot` y sigue los pasos
   - Copia el token (ej: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

2. **Ir a Railway:**
   - Abre https://railway.app
   - Usa GitHub login (o email)

3. **Crear nuevo proyecto:**
   - Click en "New Project"
   - Selecciona "Deploy from GitHub repo"
   - Conecta tu repo `Jarvis-IA`

4. **Configurar variables:**
   - En Railway, ve a "Variables"
   - Añade: `TELEGRAM_BOT_TOKEN=tu_token_aqui`

5. **Deploy:**
   - Railway automáticamente corre `python hermes_telegram_bot.py`
   - ✅ ¡Tu bot está 24/7!

**Ventajas:**
- ✅ 100% Gratuito
- ✅ Ejecuta 24/7
- ✅ Auto-redeploy en cada push

---

## Opción 2: Render (Gratuito)

Similar a Railway pero con interfaz diferente.

### Pasos:

1. **Ir a Render:**
   - https://render.com
   - Signup con GitHub

2. **Crear "Background Worker":**
   - Click "New" → "Background Worker"
   - Conecta tu repo

3. **Configurar:**
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `python hermes_telegram_bot.py`
   - Añade variable: `TELEGRAM_BOT_TOKEN=tu_token`

4. **Deploy:**
   - ✅ Automático

---

## Opción 3: PythonAnywhere (Gratuito)

Para usuarios que prefieren Python puro.

### Pasos:

1. **Ir a https://www.pythonanywhere.com**
2. **Crear cuenta gratuita**
3. **Upload archivos:**
   - `hermes_telegram_bot.py`
   - `requirements.txt`

4. **Web App:**
   - Consola: `pip install -r requirements.txt`
   - Always-on (si tienes account premium, 5$ mes)

---

## Opción 4: Replit (Muy Fácil)

Para usuarios que quieren codificar online.

### Pasos:

1. **Ir a https://replit.com**
2. **Importar repositorio:**
   - Click "Import from GitHub"
   - Pega: `https://github.com/tu_usuario/Jarvis-IA`

3. **Configurar Secretos:**
   - Click 🔒 "Secrets"
   - `TELEGRAM_BOT_TOKEN=tu_token`

4. **Ejecutar:**
   - Click "Run"
   - ✅ Listo

**Nota:** En tier gratuito de Replit, el bot se detiene después de 1 hora inactivo. Usa **Replit Bouncer** (gratuito) para mantenerlo activo.

---

## Opción 5: Servidor Local (Tu Máquina)

Si tienes una máquina siempre encendida:

### Setup Local:

```bash
# Instalar dependencias
pip install -r requirements.txt

# Configurar token
export TELEGRAM_BOT_TOKEN="tu_token_aqui"

# Ejecutar
python hermes_telegram_bot.py
```

### Para que se ejecute siempre:

**En Linux/Mac (systemd):**
```bash
sudo nano /etc/systemd/system/hermes-bot.service
```

Contenido:
```ini
[Unit]
Description=Hermes Telegram Bot
After=network.target

[Service]
User=tu_usuario
WorkingDirectory=/path/to/Jarvis-IA
Environment="TELEGRAM_BOT_TOKEN=tu_token"
ExecStart=/usr/bin/python3 hermes_telegram_bot.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Luego:
```bash
sudo systemctl enable hermes-bot
sudo systemctl start hermes-bot
```

**En Windows:**
- Usar Task Scheduler para ejecutar el script al iniciar

---

## Pruebas

1. Abre Telegram
2. Busca tu bot (ej: `@mi_bot_hermes`)
3. Escribe `/start`
4. Prueba: `/status` o envía un mensaje

---

## Solución Recomendada (Mejor Relación Costo-Beneficio)

**Railway** es la mejor opción porque:
- ✅ Totalmente gratuito
- ✅ 24/7 sin interrupción
- ✅ Setup en 5 minutos
- ✅ Auto-updates desde GitHub

---

## Problemas Comunes

**"Bot no responde"**
- Verifica token en variables de entorno
- Revisa logs en Railway/Render
- Asegúrate que Hermes está instalado en el servidor

**"Hermes no disponible"**
- El servidor puede no tener Hermes instalado
- Solución: Instalar Hermes en el servidor o usar API remota

**"Timeout en respuestas largas"**
- Telegram tiene límite de 4096 caracteres
- El bot automáticamente divide mensajes largos

---

## Siguientes Pasos

1. Elige tu plataforma (recomendado: Railway)
2. Sigue los pasos arriba
3. Proporciona tu token
4. ¡Hermes responderá 24/7!

---

## Support

Para preguntas sobre el bot: revisa logs en Railway/Render
Para preguntas sobre Hermes: https://hermes-agent.nousresearch.com
