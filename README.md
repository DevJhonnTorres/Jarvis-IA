# Jarvis IA

Asistente personal por Telegram, construido sobre [Hermes Agent](https://hermes-agent.nousresearch.com)
y DeepSeek, que corre **24/7 en un portátil de casa** y sobrevive a lo que suele
matar a estos proyectos: cortes de red, cierres de tapa, batería agotada y
contenedores que se reciclan.

No es un tutorial ni un experimento de fin de semana. Es el asistente que uso
todos los días, con el código, los scripts de provisión y las decisiones de
infraestructura que lo mantienen vivo.

---

## Qué hace

- **Chat con memoria por conversación** desde Telegram, con acceso a herramientas
  (ficheros, shell, búsqueda) y envío de adjuntos.
- **Skills propias** en Markdown que amplían lo que Jarvis sabe hacer
  (ej. [`skills/bateria.SKILL.md`](skills/bateria.SKILL.md), que le deja consultar
  el estado del equipo que lo hospeda).
- **Se mantiene en pie solo**: watchdog que lo relevanta, alertas de batería por
  Telegram y arranque automático con la sesión de Windows.
- **Backend intercambiable**: DeepSeek por defecto, vía API compatible con OpenAI.

## Arquitectura

```
 Telegram  ──▶  Hermes Gateway  ──▶  Hermes Agent  ──▶  DeepSeek API
                      │                    │
                      │                    └──▶  Skills  (skills/*.SKILL.md)
                      │                    └──▶  Tools   (shell, ficheros, web)
                      │
                      └──▶  Host Windows 24/7
                             ├── watchdog_jarvis.sh        relevanta el gateway
                             ├── battery_monitor.ps1       alerta por Telegram
                             ├── windows_always_on.ps1     sin suspensión ni hibernación
                             └── enable_virtual_display.ps1 pantalla virtual para AnyDesk
```

## Puesta en marcha

Necesitas una `DEEPSEEK_API_KEY` y un token de bot de [@BotFather](https://t.me/BotFather).

**Linux / macOS**

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

git clone https://github.com/DevJhonnTorres/Jarvis-IA.git
cd Jarvis-IA

export DEEPSEEK_API_KEY=sk-...
./setup_jarvis.sh          # identidad, reglas, memoria, modelo y credencial

hermes gateway run         # el bot ya responde en Telegram
```

**Windows** (PowerShell como administrador)

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
.\setup_jarvis.ps1
hermes gateway install --start-now --start-on-login
.\windows_always_on.ps1    # nada de suspensión: el bot tiene que seguir ahí
```

El detalle completo está en [WINDOWS_DEPLOY.md](WINDOWS_DEPLOY.md).

## Estructura

| Ruta | Para qué sirve |
|---|---|
| `setup_jarvis.sh` / `setup_jarvis.ps1` | Provisiona `~/.hermes` desde cero: identidad, reglas, memoria, perfil y modelo |
| `skills/` | Skills propias en Markdown que Hermes carga como capacidades nuevas |
| `watchdog_jarvis.sh` | Vigila el gateway y lo relevanta si el proceso muere |
| `battery_monitor.ps1` | Avisa por Telegram al desenchufar y por debajo del 40 % y 20 % |
| `windows_always_on.ps1` | Deja el equipo despierto con la tapa cerrada |
| `enable_virtual_display.ps1` | Monitor virtual para que AnyDesk no muestre pantalla negra |
| `keep_alive.py` | Servidor Flask de *health check* para plataformas que duermen procesos inactivos |
| `deepsek_integration.py` | Cliente de DeepSeek vía SDK compatible con OpenAI |
| `hermes_telegram_bot.py` | Bot de Telegram original — **obsoleto**, sustituido por el gateway nativo |

## Dónde desplegarlo

| Documento | Entorno | Nota |
|---|---|---|
| [WINDOWS_DEPLOY.md](WINDOWS_DEPLOY.md) | PC propio | La que uso: sin coste y sin reciclado de contenedores |
| [GCP_DEPLOY.md](GCP_DEPLOY.md) | Google Cloud | VM con systemd, capa gratuita |
| [DEPLOY_RAILWAY.md](DEPLOY_RAILWAY.md) | Railway | Despliegue en 5 minutos desde el repo |
| [REPLIT_SETUP.md](REPLIT_SETUP.md) | Replit | Gratis, necesita `keep_alive.py` |
| [NOVNC_SETUP.md](NOVNC_SETUP.md) | Navegador | Escritorio remoto sin instalar nada |

## Decisiones técnicas que merecen una nota

- **El gateway nativo sustituyó al bot propio.** `hermes_telegram_bot.py` lanzaba
  un `hermes -z` por mensaje: cero contexto entre turnos. El gateway mantiene
  sesión por chat, herramientas dentro de la conversación y envío de ficheros.
  Los dos a la vez hacen *long polling* sobre el mismo token y Telegram responde
  409, así que solo puede correr uno.
- **Por qué existe un monitor virtual.** El portátil tiene Intel UHD con una sola
  pantalla. Al cerrar la tapa la GPU se queda sin display activo y AnyDesk
  captura una pantalla negra — no es suspensión, es que no queda nada que
  renderizar. Ninguna opción de energía lo arregla; un monitor virtual, sí.
- **Por qué hay watchdog.** El adaptador de Telegram se rinde tras 10 reintentos
  de red y el proceso sale. Sin vigilancia, un corte de red deja el bot mudo
  hasta que alguien vuelva a encender la máquina.
- **El monitor de batería no pasa por el modelo.** Habla directo con la API de
  Telegram: las alertas de infraestructura no deberían consumir créditos.

## Configuración

Copia [`.env.example`](.env.example) a `.env` y rellénalo. Las claves nunca se
commitean: `.env` está en `.gitignore`.

| Variable | Obligatoria | Para qué |
|---|---|---|
| `DEEPSEEK_API_KEY` | sí | Acceso al modelo |
| `TELEGRAM_BOT_TOKEN` | sí | Token del bot, de @BotFather |
| `HERMES_HOME` | no | Ubicación de la configuración (por defecto `~/.hermes`) |

## Licencia

MIT — pendiente de añadir el fichero `LICENSE`.
