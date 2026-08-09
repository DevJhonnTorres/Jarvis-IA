#!/usr/bin/env bash
# Despliega a Jarvis en una VM de Google Cloud (e2-micro, capa gratuita).
#
# ESTE SCRIPT SE EJECUTA DENTRO DE LA VM, no acá.
# Ver GCP_DEPLOY.md para cómo crear la VM y conectarte.
#
# Deja a Jarvis corriendo bajo systemd, que es el supervisor que el propio
# código de Hermes espera: cuando el adaptador de Telegram agota sus 10
# reintentos de red y se declara fatal, systemd lo vuelve a levantar. En el
# contenedor remoto ese supervisor no existía y por eso el proceso moría.
#
# Uso:
#   export DEEPSEEK_API_KEY=sk-...
#   export TELEGRAM_BOT_TOKEN=...
#   export TELEGRAM_ALLOWED_USERS=8184434996
#   ./deploy_gcp.sh

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/DevJhonnTorres/Jarvis-IA.git}"
REPO_DIR="${REPO_DIR:-$HOME/Jarvis-IA}"

for v in DEEPSEEK_API_KEY TELEGRAM_BOT_TOKEN; do
    if [ -z "${!v:-}" ]; then
        echo "❌ Falta $v"
        echo "   export $v=..."
        exit 1
    fi
done

echo "▸ 1/6  Dependencias del sistema"
sudo apt-get update -qq
sudo apt-get install -y -qq git curl python3 ca-certificates

# La e2-micro trae 1 GB de RAM. El gateway usa ~145 MB, así que alcanza, pero
# sin swap cualquier pico (una skill pesada, un build) mata el proceso por OOM.
echo "▸ 2/6  Swap de 2 GB (la e2-micro tiene solo 1 GB de RAM)"
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile >/dev/null
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
    echo "   swap creado"
else
    echo "   ya existía"
fi

echo "▸ 3/6  Hermes Agent"
if command -v hermes >/dev/null 2>&1; then
    echo "   ya instalado: $(hermes --version 2>&1 | head -1)"
else
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    export PATH="$PATH:/usr/local/bin"
fi

echo "▸ 4/6  Repositorio"
if [ -d "$REPO_DIR/.git" ]; then
    git -C "$REPO_DIR" pull --ff-only
else
    git clone "$REPO_URL" "$REPO_DIR"
fi

echo "▸ 5/6  Configuración de Jarvis"
cd "$REPO_DIR"
chmod +x setup_jarvis.sh
./setup_jarvis.sh

echo "▸ 6/6  Servicio systemd"
# --system     : arranca en el boot de la VM, no al login
# --start-now  : lo levanta ya
hermes gateway install --system --start-now --start-on-login --run-as-user "$USER"

echo
echo "✅ Jarvis desplegado"
echo
echo "Comprobar:"
echo "  hermes gateway status"
echo "  systemctl status hermes-gateway"
echo "  journalctl -u hermes-gateway -f"
echo
echo "Prueba real: escribile al bot por Telegram."
