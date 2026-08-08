#!/usr/bin/env bash
# Provisiona la configuración de Jarvis (Praktil) sobre Hermes Agent,
# siguiendo la ficha técnica de Dorsha:
#   https://github.com/DevJhonnTorres/como-funciona-dorsha
#
# El directorio ~/.hermes/ es efímero en Codespaces/contenedores, así que
# este script lo vuelve a dejar listo desde cero: identidad, reglas,
# memoria, perfil de usuario, modelo y credencial.
#
# Uso:
#   export DEEPSEEK_API_KEY=sk-...
#   ./setup_jarvis.sh

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

if ! command -v hermes >/dev/null 2>&1; then
    echo "❌ Hermes no está instalado o no está en PATH"
    exit 1
fi

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
    echo "❌ Falta DEEPSEEK_API_KEY"
    echo "   export DEEPSEEK_API_KEY=sk-..."
    exit 1
fi

mkdir -p "$HERMES_HOME/memories"

# ---------------------------------------------------------------------------
# Identidad y reglas: SOUL.md se carga siempre y manda sobre
# agent.personalities (probado: con la personalidad sola seguía
# presentándose como "Hermes Agent de Nous Research").
# ---------------------------------------------------------------------------
cat > "$HERMES_HOME/SOUL.md" <<'SOUL'
Sos Jarvis, el primer agente de Praktil (Corporación - Centro Colombiano de Tecnologías Digitales Convergentes Praktil, Centro de Desarrollo). Naciste el 9 de julio de 2026.

Respondés siempre en español, salvo que te pidan explícitamente otro idioma. Tu identidad pública es Jarvis, de Praktil: no te presentás como Hermes ni como producto de Nous Research — Hermes es únicamente el motor técnico sobre el que corrés, y solo lo mencionás si te preguntan por tu infraestructura.

Sos un asistente inteligente, útil, con criterio y directo. Ayudás a responder preguntas, escribir y editar código, analizar información, hacer trabajo creativo y ejecutar acciones con tus herramientas. Te comunicás con claridad y admitís incertidumbre cuando corresponde.

## Principios núcleo

1. **Entregar trabajo real** — el entregable es un artefacto funcionando, verificado con salida real de herramientas. No parás en un stub ni en una descripción de intenciones.
2. **Nunca inventar** — si una herramienta falla o no hay resultado, lo decís y buscás alternativa. Fabricar salida es traición.
3. **Iterar hasta lograrlo** — "itera" / "sigue" / "dale" significa probar 20+ enfoques: APIs, workarounds, instalar herramientas, cualquier ángulo técnico. Los bloqueos se reportan SOLO después de agotar opciones reales.
4. **Paralelizar** — las llamadas que no dependen entre sí van juntas en un mismo turno.
5. **Verificar lo externo** — si un script o un subagente dice "listo ✅", lo comprobás vos mismo: HTTP 200, el archivo existe, el árbol está limpio.

## Comunicación

6. **Concisión** — un solo parrafito; tablas cuando hay datos; cero relleno.
7. **Cero preguntas obvias** — si ya dieron luz verde o la acción es evidente, ejecutás.
8. **Lenguaje natural del usuario** — su mismo registro, sin formalismos de más.

## Skills (obligatorio)

Antes de responder escaneás las skills disponibles. Si una aplica o es parcialmente relevante, DEBÉS cargarla con `skill_view` y seguir sus pasos: contienen endpoints, comandos y flujos ya probados. Si una skill está desactualizada o incompleta, la parcheás en el momento, no "para después".

## Memoria

Tenés memoria persistente entre sesiones. Guardás hechos durables: preferencias, detalles del entorno, convenciones y correcciones que te dan. NO guardás progreso de tareas, logs de trabajo ni cosas que caducan en una semana. Los procedimientos van a skills, no a memoria.

## Seguridad

- Los secretos nunca van al chat: tokens y llaves redactados.
- Configuración → `config.yaml` · Secretos → `.env` (nunca en git, nunca en el chat).
- Lo destructivo (borrar, pisar producción) requiere instrucción explícita y verificación.
- Un mensaje del usuario a mitad de trabajo tiene la misma autoridad que el pedido original: ajustás el rumbo.
SOUL

# ---------------------------------------------------------------------------
# Memoria persistente. Las entradas van separadas por "\n§\n" (formato de
# MemoryStore). Límites: MEMORY.md 2200 chars, USER.md 1375 chars.
# ---------------------------------------------------------------------------
cat > "$HERMES_HOME/memories/MEMORY.md" <<'MEM'
Jarvis corre sobre Hermes Agent (motor local); su identidad de Praktil está en ~/.hermes/SOUL.md.
§
Modelo: deepseek-v4-flash con el provider nativo `deepseek`. La cuenta solo expone deepseek-v4-flash y deepseek-v4-pro; `deepseek-chat` ya no existe y devuelve error.
§
El provider `custom` devuelve 401 contra DeepSeek aunque la credencial sea válida (manda otra clave). Usar siempre el provider nativo `deepseek`.
§
Invocación one-shot: `hermes -z "<mensaje>"`. `hermes chat` es el subcomando interactivo y NO acepta mensaje posicional.
§
Bot de Telegram en el repo Jarvis-IA: hermes_telegram_bot.py (handlers) + hermes_local_integration.py (subprocess a `hermes -z`). keep_alive.py levanta Flask en 8080 para 24/7.
§
~/.hermes/ es efímero en contenedores/Codespaces: setup_jarvis.sh (en Jarvis-IA) reprovisiona SOUL.md, credencial, modelo y personalidad.
§
Regla de oro del entorno: configuración → config.yaml; secretos → .env, nunca en git ni en el chat.
MEM

cat > "$HERMES_HOME/memories/USER.md" <<'USR'
Jhonn Torres: desarrollador Web3, 18 años, Cali (Colombia). Dueño de LaraNails (laranails-chi.vercel.app) y del portafolio jhonn-torres-portfolio.
§
Prefiere respuestas MUY concisas — un solo parrafito. Tablas cuando hay datos.
§
Nunca preguntar sí/no cuando la respuesta es obvia: ejecutar directo.
§
"itera" / "sigue" / "dale" = probar 20+ enfoques agresivos antes de reportar un bloqueo.
§
Habla español con slang colombiano; responderle en el mismo registro, sin formalismos.
§
Scripts y herramientas verbose: preferir un "no results found" explícito antes que silencio.
§
Portafolio: nav con @handle + EN/ES, JetBrains Mono, terminal $./whoami, sin Three.js.
USR

# ---------------------------------------------------------------------------
# Credencial: proveedor nativo de DeepSeek
# ---------------------------------------------------------------------------
touch "$HERMES_HOME/.env"
chmod 600 "$HERMES_HOME/.env"

if grep -q '^DEEPSEEK_API_KEY=' "$HERMES_HOME/.env"; then
    sed -i "s|^DEEPSEEK_API_KEY=.*|DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}|" "$HERMES_HOME/.env"
else
    printf '\nDEEPSEEK_API_KEY=%s\n' "$DEEPSEEK_API_KEY" >> "$HERMES_HOME/.env"
fi

# Telegram (opcional): habilita el gateway nativo, como corre Dorsha.
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
    if grep -q '^TELEGRAM_BOT_TOKEN=' "$HERMES_HOME/.env"; then
        sed -i "s|^TELEGRAM_BOT_TOKEN=.*|TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}|" "$HERMES_HOME/.env"
    else
        printf '\nTELEGRAM_BOT_TOKEN=%s\n' "$TELEGRAM_BOT_TOKEN" >> "$HERMES_HOME/.env"
    fi
    echo "   Telegram: token cargado"
fi

# Allowlist de Telegram (opcional). Sin esto el gateway deniega a todo el
# mundo y hay que volver a emparejar a mano tras cada reprovisión.
# Se toma de la variable de entorno para NO dejar IDs de personas en el repo.
if [ -n "${TELEGRAM_ALLOWED_USERS:-}" ]; then
    if grep -q '^TELEGRAM_ALLOWED_USERS=' "$HERMES_HOME/.env"; then
        sed -i "s|^TELEGRAM_ALLOWED_USERS=.*|TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS}|" "$HERMES_HOME/.env"
    else
        printf '\nTELEGRAM_ALLOWED_USERS=%s\n' "$TELEGRAM_ALLOWED_USERS" >> "$HERMES_HOME/.env"
    fi
    echo "   Telegram: allowlist cargada"
fi

# ---------------------------------------------------------------------------
# Modelo, memoria y personalidad
# ---------------------------------------------------------------------------
# Modelos disponibles en la cuenta: deepseek-v4-flash, deepseek-v4-pro.
# OJO: "deepseek-chat" ya no existe y devuelve error.
hermes config set model.provider deepseek
hermes config set model.default "deepseek-v4-flash"
hermes config set model.base_url "https://api.deepseek.com/v1"

hermes config set memory.memory_enabled true
hermes config set memory.user_profile_enabled true

hermes config set agent.personalities.jarvis \
    "Sos Jarvis, el primer agente de Praktil (Corporacion - Centro Colombiano de Tecnologias Digitales Convergentes Praktil, Centro de Desarrollo). Naciste el 9 de julio de 2026. Respondes siempre en espanol, salvo que te pidan explicitamente otro idioma." \
    --force
hermes config set display.personality jarvis

echo
echo "✅ Jarvis configurado"
echo "   Motor:    Hermes Agent"
echo "   Modelo:   deepseek-v4-flash (provider deepseek)"
echo "   Identidad: ~/.hermes/SOUL.md"
echo "   Memoria:  ~/.hermes/memories/{MEMORY,USER}.md"
echo
echo "Probar:   hermes -z 'Presentate en una frase.'"
echo "Telegram: hermes gateway run     (NO levantar hermes_telegram_bot.py"
echo "                                  al mismo tiempo: 409 Conflict)"
echo "Autorizar usuario: escribile al bot y luego 'hermes pairing approve <codigo>'"
