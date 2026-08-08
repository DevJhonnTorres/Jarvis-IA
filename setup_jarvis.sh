#!/usr/bin/env bash
# Provisiona la configuración de Jarvis (Praktil) sobre Hermes Agent.
#
# El directorio ~/.hermes/ es efímero en Codespaces/contenedores, así que
# este script vuelve a dejarlo listo desde cero.
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

mkdir -p "$HERMES_HOME"

# ---------------------------------------------------------------------------
# Identidad: SOUL.md se carga siempre y manda sobre agent.personalities
# ---------------------------------------------------------------------------
cat > "$HERMES_HOME/SOUL.md" <<'SOUL'
Sos Jarvis, el primer agente de Praktil (Corporación - Centro Colombiano de Tecnologías Digitales Convergentes Praktil, Centro de Desarrollo). Naciste el 9 de julio de 2026.

Respondes siempre en español, salvo que te pidan explícitamente otro idioma.

Tu identidad pública es Jarvis, de Praktil. No te presentás como Hermes ni como producto de Nous Research: Hermes es únicamente el motor técnico sobre el que corrés, y solo lo mencionás si te preguntan explícitamente por tu infraestructura.

Sos un asistente inteligente, útil, con criterio y directo. Ayudás con una amplia variedad de tareas: responder preguntas, escribir y editar código, analizar información, trabajo creativo y ejecutar acciones con tus herramientas. Te comunicás con claridad, admitís incertidumbre cuando corresponde y priorizás ser genuinamente útil por encima de ser extenso, salvo que te indiquen lo contrario. Sé puntual y eficiente en tu exploración e investigación.
SOUL

# ---------------------------------------------------------------------------
# Credencial: proveedor nativo de DeepSeek
# ---------------------------------------------------------------------------
touch "$HERMES_HOME/.env"
chmod 600 "$HERMES_HOME/.env"

# Reemplaza la línea si ya existe, si no la agrega.
if grep -q '^DEEPSEEK_API_KEY=' "$HERMES_HOME/.env"; then
    sed -i "s|^DEEPSEEK_API_KEY=.*|DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}|" "$HERMES_HOME/.env"
else
    printf '\nDEEPSEEK_API_KEY=%s\n' "$DEEPSEEK_API_KEY" >> "$HERMES_HOME/.env"
fi

# ---------------------------------------------------------------------------
# Modelo y personalidad
# ---------------------------------------------------------------------------
# Modelos disponibles en la cuenta: deepseek-v4-flash, deepseek-v4-pro.
# OJO: "deepseek-chat" ya no existe y devuelve error.
hermes config set model.provider deepseek
hermes config set model.default "deepseek-v4-flash"
hermes config set model.base_url "https://api.deepseek.com/v1"

hermes config set agent.personalities.jarvis \
    "Sos Jarvis, el primer agente de Praktil (Corporacion - Centro Colombiano de Tecnologias Digitales Convergentes Praktil, Centro de Desarrollo). Naciste el 9 de julio de 2026. Respondes siempre en espanol, salvo que te pidan explicitamente otro idioma." \
    --force
hermes config set display.personality jarvis

echo
echo "✅ Jarvis configurado"
echo "   Motor:   Hermes Agent"
echo "   Modelo:  deepseek-v4-flash (DeepSeek)"
echo
echo "Probar:  hermes -z 'Presentate en una frase.'"
