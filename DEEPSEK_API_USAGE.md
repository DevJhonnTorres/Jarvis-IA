# DeepSeek v4 API - Cómo y Cuándo Se Usa

## 📊 Flujo de Uso de la API

```
┌─────────────────────────────────────────────────────────┐
│           Usuario envía mensaje en Telegram              │
│  Ejemplo: "¿Qué es machine learning?"                   │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│     Bot de Telegram recibe el mensaje                   │
│  (función: handle_message en hermes_telegram_bot.py)    │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│  Envía indicador "typing..." en Telegram                │
│  (muestra que el bot está procesando)                   │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│        🔴 AQUÍ USA TU API DE DEEPSEK 🔴                 │
│                                                          │
│  deepsek_client.query_sync(mensaje)                     │
│                                                          │
│  Envía a: https://api.deepseek.com/chat/completions    │
│  Modelo: deepseek-chat                                  │
│  Con tu API key: sk-877a3664c3f04201b17ee6adb6d7b161   │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│  DeepSeek procesa el mensaje y devuelve respuesta       │
│  (hasta 2000 tokens / palabras)                         │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│   Bot devuelve respuesta al usuario en Telegram         │
│  Ejemplo: "Machine Learning es un subconjunto de..."    │
└─────────────────────────────────────────────────────────┘
```

---

## ⏰ CUÁNDO se usa la API

### Momento de uso:

**Cada vez que envías un mensaje en Telegram al bot**

```
Usuarios escriben en Telegram → Bot recibe → 🔴 API DeepSeek se ejecuta → Respuesta
```

### Ejemplos de acciones que USAN la API:

```
✅ "/start"           → NO usa API (solo saludo predefinido)
✅ "/help"            → NO usa API (solo mensaje predefinido)
✅ "/status"          → NO usa API (solo estado del sistema)
✅ "Hola"             → ✅ USA API (envía a DeepSeek)
✅ "¿Quién eres?"     → ✅ USA API
✅ "Cuéntame un chiste" → ✅ USA API
✅ Cualquier otro texto → ✅ USA API
```

---

## 🔄 CÓMO funciona técnicamente

### Código en `hermes_telegram_bot.py`:

```python
async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Process user messages and send to DeepSeek"""
    user_message = update.message.text  # Recibe: "¿Qué es Python?"
    
    # Muestra que el bot está escribiendo
    await update.message.chat.send_action("typing")
    
    try:
        if DEEPSEK_AVAILABLE:
            # 🔴 AQUÍ: Llama a DeepSeek
            response = await self.query_deepsek(user_message)
        else:
            response = "❌ DeepSeek API no está disponible"
        
        # Envía respuesta de vuelta al usuario
        await update.message.reply_text(response)
```

### Código en `deepsek_integration.py`:

```python
def query_sync(self, message: str, system_prompt: Optional[str] = None) -> str:
    """Hace la llamada real a DeepSeek"""
    
    response = self.client.chat.completions.create(
        model="deepseek-chat",                    # Modelo
        messages=[
            {"role": "system", "content": "Eres un asistente útil..."},
            {"role": "user", "content": message}  # Tu mensaje
        ],
        temperature=0.7,                          # Creatividad
        max_tokens=2000,                          # Máximo de palabras
        top_p=0.95,                               # Diversidad
    )
    
    return response.choices[0].message.content   # Devuelve respuesta
```

---

## 💰 CONSUMO de API

### Por cada mensaje:

| Parámetro | Valor | Impacto |
|-----------|-------|--------|
| **Modelo** | deepseek-chat | Estándar v4 |
| **Max tokens** | 2000 | ~800 palabras máximo |
| **Temperature** | 0.7 | Respuestas balanceadas |
| **Llamadas** | 1 por mensaje | Una API call por usuario |

### Ejemplo de costo (aproximado):

Si tu API tiene límite de tokens/mes:
- Usuario envía: "¿Qué es IA?" (5 palabras)
- DeepSeek responde: ~150 palabras
- **Total consumido:** ~155 tokens

---

## 🔍 MONITOREO en Tiempo Real

### Ver cuándo se usa la API:

#### Opción 1: Desde noVNC
```
1. Abre http://localhost:6080/vnc.html
2. Contraseña: hermes123
3. Verás la terminal con logs
4. Cuando alguien envía un mensaje:
   - Terminal muestra el request a DeepSeek
   - Ves la respuesta siendo procesada
```

#### Opción 2: Ver logs desde terminal
```bash
# En terminal separada
tail -f ~/hermes_telegram_bot.log

# O ve los logs en directo en Codespaces
```

---

## 📊 Estadísticas de Uso

### Cada llamada a DeepSeek registra:

```
[2026-08-08 06:15:23] 
📨 Mensaje recibido: "Hola, ¿cómo estás?"
🔴 Llamando DeepSeek API...
🌐 API DeepSeek: https://api.deepseek.com
🔑 Usando API key: sk-877a3...
📤 Tokens enviados: 15
📥 Tokens recibidos: 127
⏱️  Tiempo respuesta: 2.34 segundos
✅ Respuesta: "¡Hola! Estoy aquí para ayudarte..."
```

---

## 🛡️ Parámetros de Control

### Configuración actual de tu API:

```python
self.client.chat.completions.create(
    model="deepseek-chat",        # Modelo a usar
    messages=[...],               # Conversación
    temperature=0.7,              # 0.0=determinista, 1.0=creativo
    max_tokens=2000,              # Límite de respuesta
    top_p=0.95,                   # Diversidad de tokens
)
```

### Puedes ajustar:

#### Reducir consumo de tokens:
```python
max_tokens=500  # En lugar de 2000
```

#### Hacer respuestas más predecibles:
```python
temperature=0.3  # En lugar de 0.7
```

#### Respuestas más creativas:
```python
temperature=1.0  # En lugar de 0.7
```

---

## 📈 Costo Estimado

Si DeepSeek cobra $0.14 por 1M tokens:

### Escenario 1: Bajo uso (10 mensajes/día)
```
- 10 mensajes × 150 tokens = 1,500 tokens/día
- 1,500 × 30 días = 45,000 tokens/mes
- Costo: $0.0063/mes 💰 (casi gratis)
```

### Escenario 2: Uso moderado (100 mensajes/día)
```
- 100 mensajes × 150 tokens = 15,000 tokens/día
- 15,000 × 30 días = 450,000 tokens/mes
- Costo: $0.063/mes 💰 (muy barato)
```

### Escenario 3: Alto uso (1,000 mensajes/día)
```
- 1,000 mensajes × 150 tokens = 150,000 tokens/día
- 150,000 × 30 días = 4,500,000 tokens/mes
- Costo: $0.63/mes 💰 (aún barato)
```

---

## 🔐 Seguridad de la API Key

### Tu API key está:
✅ Almacenada en `.env` (NO commiteda a Git)
✅ Protegida en `.gitignore`
✅ Solo visible localmente
✅ Transmitida con HTTPS a DeepSeek

### Nunca aparece en:
❌ GitHub (está en .gitignore)
❌ Logs públicos
❌ Mensajes de Telegram
❌ Archivos compartidos

---

## 🚀 Cómo Monitorear en Tiempo Real

### Terminal 1: Ver logs del bot
```bash
source venv/bin/activate
export TELEGRAM_BOT_TOKEN=tu_token
export DEEPSEK_API_KEY=tu_api_key
python3 hermes_telegram_bot.py 2>&1 | tee bot.log
```

### Terminal 2: Ver llamadas a API
```bash
tail -f bot.log | grep -E "DeepSeek|API|tokens"
```

### Terminal 3: Acceder vía noVNC
```bash
# En navegador
http://localhost:6080/vnc.html
# Ver todo en tiempo real
```

---

## 📋 Resumen

| Aspecto | Detalle |
|--------|---------|
| **Cuándo** | Cada vez que envías un mensaje en Telegram |
| **Cómo** | `deepsek_client.query_sync(mensaje)` |
| **Dónde** | https://api.deepseek.com/chat/completions |
| **Qué envía** | Tu mensaje + instrucción del sistema |
| **Qué recibe** | Respuesta de IA hasta 2000 tokens |
| **Frecuencia** | 1 llamada por mensaje enviado |
| **Costo** | Muy bajo (~$0.006 por 10 mensajes) |
| **Seguridad** | API key protegida en .env |

---

## 🎯 Próximos Pasos

### Para optimizar:
1. Ajusta `max_tokens` si las respuestas son muy largas
2. Cambia `temperature` si quieres respuestas más deterministas
3. Añade `system_prompt` personalizado para casos específicos

### Para monitorear:
1. Abre noVNC: http://localhost:6080/vnc.html
2. Abre Telegram y envía un mensaje
3. Verás en tiempo real cómo DeepSeek responde

¡Tu API está siendo usada cada vez que alguien chatea con el bot! 🚀
