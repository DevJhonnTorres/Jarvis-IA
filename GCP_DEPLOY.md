# Desplegar Jarvis en Google Cloud (capa gratuita)

Para que Jarvis deje de morirse. En el contenedor remoto de Claude Code el
problema no tiene arreglo: se recicla cada pocas horas y mata todos los
procesos. En una VM con systemd eso desaparece.

## Por qué esto arregla las caídas

El código de Hermes, cuando el adaptador de Telegram agota sus 10 reintentos
de red (~7,2 minutos), hace esto:

```python
self._set_fatal_error("telegram_network_error", message, retryable=True)
await self._handoff_polling_fatal_error()
```

Su propio docstring dice: *"mark the adapter retryable-fatal so **the
supervisor restarts the gateway process**"*. Ese supervisor es systemd — en
el contenedor no existía (PID 1 era `process_api`) y la pelota caía al piso.

| Causa de muerte | En el contenedor | En la VM |
|---|---|---|
| Reciclado del host | ~4-5 h caído | No pasa |
| Red > 7,2 min | Muere y no vuelve | systemd lo revive |
| Doble poller (409) | Guardas de idempotencia | Igual |
| Saldo agotado (402) | No aplica | No aplica — hay que recargar |

## 1. Crear la VM

En https://console.cloud.google.com → Compute Engine → Crear instancia.

| Campo | Valor |
|---|---|
| Tipo de máquina | **e2-micro** |
| Región | Una elegible para capa gratuita (suelen ser regiones de EE. UU.) |
| Disco | 30 GB estándar |
| Sistema | Debian 12 o Ubuntu 22.04 |
| Firewall | No hace falta abrir nada |

> Verificá las condiciones vigentes de la capa gratuita antes de crear la
> instancia: los tipos y regiones elegibles cambian, y una región equivocada
> te factura.

Nada de puertos abiertos: el gateway usa *long polling* saliente hacia
Telegram, no recibe conexiones entrantes.

## 2. Conectarte

Botón **SSH** en la consola de GCP, o:

```bash
gcloud compute ssh jarvis --zone TU-ZONA
```

## 3. Desplegar

Dentro de la VM:

```bash
git clone https://github.com/DevJhonnTorres/Jarvis-IA.git
cd Jarvis-IA

export DEEPSEEK_API_KEY=sk-...
export TELEGRAM_BOT_TOKEN=...
export TELEGRAM_ALLOWED_USERS=8184434996

chmod +x deploy_gcp.sh
./deploy_gcp.sh
```

El script instala dependencias, crea 2 GB de swap, instala Hermes, corre
`setup_jarvis.sh` (identidad, memoria, perfil, modelo, credenciales) y deja
el servicio de systemd andando.

## 4. Comprobar

```bash
hermes gateway status
systemctl status hermes-gateway
journalctl -u hermes-gateway -f
```

Y la prueba que vale: escribile al bot por Telegram.

## Notas

**RAM.** La e2-micro trae 1 GB. El gateway consume ~145 MB, así que sobra,
pero el script agrega 2 GB de swap porque sin margen cualquier pico se lleva
el proceso por OOM. No habilites STT local (`faster-whisper`) en esta
máquina: los modelos pesan cientos de MB.

**Apagar el contenedor.** Cuando la VM esté andando, matá el gateway de acá.
Dos pollers sobre el mismo token = 409 Conflict y el bot deja de responder:

```bash
pkill -f "[h]ermes gateway run"
pkill -f "[w]atchdog_jarvis.sh"
```

**Saldo.** Nada de esto sirve con la cuenta de DeepSeek en cero: el proceso
va a estar vivo y cada mensaje va a fallar con `HTTP 402 Insufficient
Balance`. Recargá primero en https://platform.deepseek.com/top_up

**Actualizar.** `git pull && ./setup_jarvis.sh && sudo systemctl restart hermes-gateway`
