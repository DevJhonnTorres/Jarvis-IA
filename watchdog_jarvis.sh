#!/usr/bin/env bash
# Vigila el gateway de Jarvis y lo vuelve a levantar si se cae.
#
# Por qué existe: el adaptador de Telegram se rinde tras 10 reintentos de red
# y el proceso SALE. Si al contenedor se le va la red un rato (pasa cuando la
# sesión queda inactiva), el gateway muere y no vuelve solo.
#
# Uso:
#   nohup ./watchdog_jarvis.sh > /dev/null 2>&1 &
#
# Intervalo por defecto 60s:  WATCHDOG_INTERVAL=30 ./watchdog_jarvis.sh

set -uo pipefail

INTERVAL="${WATCHDOG_INTERVAL:-60}"
GATEWAY_LOG="${GATEWAY_LOG:-/tmp/jarvis_gateway.log}"
WATCHDOG_LOG="${WATCHDOG_LOG:-/tmp/jarvis_watchdog.log}"

# OJO con el patrón [h]ermes: sin los corchetes, pgrep -f encuentra a este
# mismo script (su cmdline contiene el patrón) y el watchdog creería que el
# gateway está vivo para siempre.
PATTERN="[h]ermes gateway run"

log() { echo "$(date -u '+%F %T UTC') $*" >> "$WATCHDOG_LOG"; }

log "watchdog iniciado (intervalo ${INTERVAL}s)"

while true; do
    if ! pgrep -f "$PATTERN" >/dev/null 2>&1; then
        log "gateway caído -> relanzando"
        nohup hermes gateway run >> "$GATEWAY_LOG" 2>&1 &
        sleep 10
        if pgrep -f "$PATTERN" >/dev/null 2>&1; then
            log "gateway arriba de nuevo (PID $(pgrep -f "$PATTERN" | head -1))"
        else
            log "ERROR: no levantó — revisar $GATEWAY_LOG"
        fi
    fi
    sleep "$INTERVAL"
done
