#!/bin/bash
# SessionStart: detiene cualquier gateway que quede corriendo en el contenedor
# remoto de Claude Code.
#
# Historia: este hook antes LEVANTABA el gateway ahí, cuando Jarvis vivía en el
# contenedor. Jarvis ya no vive ahí: corre en el PC con Windows de Jhonn, como
# tarea programada. Un gateway remoto ahora es un segundo poller sobre el mismo
# token de Telegram, y Telegram solo admite uno: el otro recibe
#
#   Conflict: terminated by other getUpdates request
#
# Los dos se pelean el turno indefinidamente (se vio en vivo: conflicto y
# reconexión cada ~22 segundos), y los mensajes salen con retraso o los atiende
# la instancia equivocada.
#
# Así que el hook hace lo contrario que antes: se asegura de que acá NO quede
# nada polleando.

set -uo pipefail

# Fuera del entorno remoto no hay nada que hacer: en la máquina de Jhonn el
# gateway es la tarea programada de Windows y NO hay que tocarla.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
    exit 0
fi

# Los corchetes evitan que pgrep -f se encuentre a sí mismo: la línea de
# comandos de este script contiene el patrón.
killed=0

if pgrep -f "[h]ermes gateway run" >/dev/null 2>&1; then
    pkill -f "[h]ermes gateway run" 2>/dev/null || true
    killed=1
fi

if pgrep -f "[w]atchdog_jarvis.sh" >/dev/null 2>&1; then
    pkill -f "[w]atchdog_jarvis.sh" 2>/dev/null || true
    killed=1
fi

if [ "$killed" -eq 1 ]; then
    echo "[jarvis] Detenido el gateway remoto: Jarvis corre en el PC de Jhonn."
    echo "[jarvis] Dos pollers sobre el mismo token dan 409 Conflict."
fi

exit 0
