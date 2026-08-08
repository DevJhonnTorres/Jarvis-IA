#!/bin/bash
# SessionStart: vuelve a levantar a Jarvis cuando arranca una sesión.
#
# Por qué: el contenedor remoto se recicla cada tanto. El disco sobrevive
# (~/.hermes conserva identidad, memoria, credenciales y pairings), pero
# TODOS los procesos mueren y nada los rearranca. Sin esto, Jarvis queda
# mudo en Telegram hasta que alguien lo levante a mano.
#
# Es idempotente: si el gateway ya corre, no arranca otro. Dos gateways
# sobre el mismo token = 409 Conflict de Telegram y el bot deja de responder.

set -uo pipefail

# Solo en el entorno remoto: en local el usuario maneja sus propios procesos.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
    exit 0
fi

HERMES_BIN="$(command -v hermes || echo /usr/local/bin/hermes)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
GATEWAY_LOG="/tmp/jarvis_gateway.log"

# Sin binario no hay nada que hacer.
if [ ! -x "$HERMES_BIN" ]; then
    echo "[jarvis] Hermes no está instalado — nada que levantar."
    exit 0
fi

# Sin credenciales el gateway arranca y muere. Mejor decirlo que fallar mudo.
if [ ! -f "$HOME/.hermes/.env" ] || ! grep -q '^TELEGRAM_BOT_TOKEN=' "$HOME/.hermes/.env" 2>/dev/null; then
    echo "[jarvis] Falta ~/.hermes/.env con TELEGRAM_BOT_TOKEN."
    echo "[jarvis] Reprovisioná con: DEEPSEEK_API_KEY=... TELEGRAM_BOT_TOKEN=... ./setup_jarvis.sh"
    exit 0
fi

# El patrón lleva corchetes a propósito: sin ellos, pgrep -f encuentra a este
# mismo script (su cmdline contiene el patrón) y creería que ya está todo vivo.
if pgrep -f "[h]ermes gateway run" >/dev/null 2>&1; then
    echo "[jarvis] gateway ya corriendo (PID $(pgrep -f "[h]ermes gateway run" | head -1))"
else
    nohup "$HERMES_BIN" gateway run >> "$GATEWAY_LOG" 2>&1 &
    sleep 8
    if pgrep -f "[h]ermes gateway run" >/dev/null 2>&1; then
        echo "[jarvis] gateway levantado (PID $(pgrep -f "[h]ermes gateway run" | head -1))"
    else
        echo "[jarvis] ERROR: el gateway no levantó — ver $GATEWAY_LOG"
    fi
fi

# Watchdog: el adaptador de Telegram se rinde tras 10 reintentos de red y el
# proceso SALE, así que hace falta algo que lo vuelva a levantar en caliente.
if [ -x "$PROJECT_DIR/watchdog_jarvis.sh" ]; then
    if pgrep -f "[w]atchdog_jarvis.sh" >/dev/null 2>&1; then
        echo "[jarvis] watchdog ya corriendo"
    else
        nohup "$PROJECT_DIR/watchdog_jarvis.sh" >/dev/null 2>&1 &
        echo "[jarvis] watchdog levantado"
    fi
fi

exit 0
