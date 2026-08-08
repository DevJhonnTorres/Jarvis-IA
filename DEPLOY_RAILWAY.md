# Deploy Hermes Bot a Railway (5 minutos)

Tu token de Telegram ya está configurado. Aquí está el proceso para ponerlo online:

## Paso 1: Preparar GitHub

Primero, asegúrate de que tu código esté pushado:

```bash
git status
# Si hay cambios pendientes:
git add .
git commit -m "Deploy: Telegram bot configuration"
git push origin main  # o tu branch
```

## Paso 2: Ir a Railway

1. Abre https://railway.app
2. Haz click en **"Login"** → Selecciona **"Login with GitHub"**
3. Autoriza Railway para acceder a tus repos

## Paso 3: Crear Proyecto

1. Click en **"New Project"** (botón azul arriba a la derecha)
2. Selecciona **"Deploy from GitHub repo"**
3. Busca y selecciona: `Jarvis-IA`
4. Confirma

## Paso 4: Configurar Variables

Railway automáticamente detectará que es Python y ejecutará el bot.

1. En la página del proyecto, haz click en **"Variables"**
2. Click en **"+ New Variable"**
3. Rellena:
   - **Name:** `TELEGRAM_BOT_TOKEN`
   - **Value:** `8526429296:AAFk5iSm5dyG1TdjcOU-XPCYiAYPt7P0KQs`
4. Click **"Add"**

## Paso 5: Deploy

Railway automáticamente:
- Detecta `requirements.txt`
- Instala dependencias
- Ejecuta `python hermes_telegram_bot.py`
- ✅ Tu bot está **ONLINE 24/7**

## ✅ Verificar que Funciona

1. Abre Telegram
2. Busca tu bot (nombre que pusiste con BotFather)
3. Escribe `/start`
4. Deberías ver:
   ```
   🤖 Hermes Agent Bot
   Bienvenido. Soy Hermes, tu asistente de IA.
   ```

5. Prueba estos comandos:
   - `/status` - Ver si Hermes está activo
   - `/help` - Ver ayuda
   - Escribe cualquier mensaje y Hermes responderá

## 📊 Ver Logs (si algo falla)

1. En Railway, ve a tu proyecto
2. Click en **"Deployments"**
3. Haz click en el deployment más reciente
4. Ve a **"Logs"** para ver qué está pasando

## 🔄 Auto-Update

Cada vez que hagas `git push` a tu repo, Railway automáticamente redeploya el código. ¡Sin hacer nada!

## ⚠️ Troubleshooting

**"Bot no responde en Telegram"**
- Espera 30 segundos después de hacer deploy
- Revisa los Logs en Railway
- Asegúrate que el token está exacto en Variables

**"Deployment failed"**
- Revisa que `requirements.txt` existe
- Revisa que `hermes_telegram_bot.py` existe
- Mira los logs para el error específico

**"Hermes no disponible"**
- Hermes necesita estar instalado en el servidor
- Solución: Usa API de Hermes remota (próximo paso)

## 🎉 ¡Hecho!

Tu bot está corriendo 24/7 en la nube. Ahora:

1. Envía mensajes a tu bot en Telegram
2. Hermes responderá automáticamente
3. No necesitas hacer nada - funciona siempre

---

## Próximos Pasos (Opcional)

Para mejor integración con Hermes:
1. Actualizar `hermes_telegram_bot.py` con API de Hermes
2. Añadir más comandos personalizados
3. Usar base de datos para historial de chats

---

**Tiempo total:** ~5 minutos ⏱️
**Costo:** $0 (totalmente gratis) 💰
