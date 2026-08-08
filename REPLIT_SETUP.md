# Hermes Telegram Bot en Replit (100% Gratis - 24/7)

Deploy tu bot en Replit en **5 minutos** sin pagar nada.

## ✅ Requisitos:
- Cuenta de Replit (gratuita en https://replit.com)
- Tu token de Telegram: `8526429296:AAFk5iSm5dyG1TdjcOU-XPCYiAYPt7P0KQs`
- Tu repo en GitHub

---

## 📋 Pasos:

### 1️⃣ Ve a Replit

https://replit.com

Click **"Sign up"** (o login si ya tienes cuenta)

### 2️⃣ Crea Proyecto desde GitHub

1. Click **"+ Create"**
2. Click **"Import from GitHub"**
3. Pega: `https://github.com/tu_usuario/Jarvis-IA`
   - (Reemplaza `tu_usuario` con tu usuario de GitHub)
4. Click **"Import"**
5. Espera a que termine de cargar (1-2 minutos)

### 3️⃣ Configura el Token (🔒 IMPORTANTE)

1. En Replit, haz click en el candado 🔒 **"Secrets"** (lado izquierdo)
2. Click **"New Secret"**
3. Rellena:
   - **Key:** `TELEGRAM_BOT_TOKEN`
   - **Value:** `8526429296:AAFk5iSm5dyG1TdjcOU-XPCYiAYPt7P0KQs`
4. Click **"Add Secret"**

✅ El token está protegido y no aparecerá en Git

### 4️⃣ Ejecuta el Bot

1. Click el botón **"Run"** (verde, arriba)
2. Deberías ver en la consola:
   ```
   ✅ Keep-alive server started on port 8080
   🚀 Iniciando Hermes Telegram Bot...
   ```

### 5️⃣ Verifica en Telegram

1. Abre Telegram
2. Busca tu bot
3. Escribe `/start`
4. Deberías recibir:
   ```
   🤖 Hermes Agent Bot
   Bienvenido. Soy Hermes, tu asistente de IA.
   ```

✅ **¡Tu bot está ACTIVO!**

---

## 🔄 Mantener el Bot Activo 24/7

El bot incluye un **Keep-Alive Server** que lo mantiene despierto.

**Cómo funciona:**
- Inicia un servidor Flask en puerto 8080
- Cada cierto tiempo, Replit lo pinga
- El bot nunca se duerme

**Archivos importantes:**
- `keep_alive.py` - Servidor Flask
- `hermes_telegram_bot.py` - Integración con el servidor

---

## ⚙️ Cambiar Código

Si cambias algo en `hermes_telegram_bot.py`:

1. Haz los cambios en Replit
2. Click **"Run"** nuevamente
3. El bot se reinicia automáticamente

O desde GitHub:
1. Pushea cambios a tu repo
2. En Replit, Click **"Version Control"** → **"Pull"**
3. Click **"Run"**

---

## 📊 Ver Logs

En la consola de Replit ves en tiempo real:
- Mensajes que recibes
- Respuestas del bot
- Errores (si los hay)

Ejemplo:
```
✅ Keep-alive server started on port 8080
🚀 Iniciando Hermes Telegram Bot...
Message from user: Hola Hermes
Sending to Hermes...
Response: ¡Hola! ¿Cómo estás?
```

---

## ⚠️ Troubleshooting

### "Bot no responde en Telegram"
1. Verifica que el token está correcto en Secrets
2. Mira los logs en la consola
3. Espera 30 segundos
4. Intenta `/start` nuevamente

### "Módulo no encontrado"
- Replit automáticamente instala `requirements.txt`
- Si falla, haz click en "Shell" y escribe:
  ```bash
  pip install -r requirements.txt
  ```

### "Error: Hermes no disponible"
- Esto es normal si Hermes no está instalado en Replit
- Próximo paso: Instalar Hermes o usar API remota

---

## 💾 Actualizar desde GitHub

Si cambias código en GitHub:

1. En Replit, haz click **"Version Control"** (izquierda)
2. Click **"Pull from main"**
3. El código se actualiza automáticamente
4. Click **"Run"** para reiniciar

---

## 🎯 Lo que ya está incluido:

✅ `hermes_telegram_bot.py` - Bot principal
✅ `keep_alive.py` - Mantiene el bot 24/7
✅ `requirements.txt` - Dependencias
✅ `.replit` - Configuración de Replit
✅ `.env.example` - Template de variables

---

## 🚀 ¡Listo!

Tu bot está corriendo **100% gratis** y **24/7** en Replit.

Cada vez que envíes un mensaje en Telegram:
1. El bot recibe el mensaje
2. Lo envía a Hermes
3. Hermes responde
4. La respuesta llega a Telegram

Todo automáticamente, sin que hagas nada.

---

## 📈 Próximos Pasos (Opcional)

- Personalizar comandos en `hermes_telegram_bot.py`
- Añadir base de datos para guardar historial
- Integrar con Hermes API remota
- Crear más funcionalidades

---

**Tiempo total:** 5 minutos ⏱️
**Costo:** $0 💰
**Uptime:** 24/7 ✅
