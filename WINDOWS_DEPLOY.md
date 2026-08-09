# Jarvis en tu PC con Windows

Para que deje de morirse. En el contenedor remoto de Claude Code no tiene
arreglo: se recicla cada pocas horas y mata todos los procesos — el hueco más
largo medido fue de **17 horas**.

Hermes corre **nativo en Windows**, no hace falta WSL.

## Por qué esto arregla las caídas

Cuando el adaptador de Telegram agota sus 10 reintentos de red (~7,2 minutos),
el código hace esto:

```python
self._set_fatal_error("telegram_network_error", message, retryable=True)
await self._handoff_polling_fatal_error()
```

Su docstring dice: *"mark the adapter retryable-fatal so **the supervisor
restarts the gateway process**"*. En el contenedor ese supervisor no existía y
el proceso quedaba muerto.

En Windows sí existe. `hermes gateway install` usa:

```
schtasks /SC ONLOGON  +  restart-on-failure
```

Una tarea programada que arranca sola y **se reinicia si el proceso falla**.
Es el equivalente exacto de systemd.

## 1. Instalar

Abrí **PowerShell** y corré:

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

Único prerequisito: **Git**. El instalador se encarga de Python, Node, ripgrep
y ffmpeg.

Cerrá y volvé a abrir PowerShell para que tome el PATH:

```powershell
hermes --version
```

## 2. Configurar a Jarvis

```powershell
git clone https://github.com/DevJhonnTorres/Jarvis-IA.git
cd Jarvis-IA

$env:DEEPSEEK_API_KEY="sk-..."
$env:TELEGRAM_BOT_TOKEN="..."
$env:TELEGRAM_ALLOWED_USERS="8184434996"

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_jarvis.ps1
```

Esto deja identidad, reglas, memoria, perfil, modelo y credenciales.

Probalo antes de seguir:

```powershell
hermes -z "Presentate en una frase."
```

Tiene que responder como Jarvis, de Praktil. Si contesta "Hermes Agent de Nous
Research", `SOUL.md` no se escribió bien.

## 3. Dejarlo como servicio

```powershell
hermes gateway install --start-now --start-on-login
hermes gateway status
```

Y la prueba que vale: escribile al bot por Telegram.

## Lo que hay que saber

**Arranca al iniciar sesión, no al prender.** `schtasks /SC ONLOGON` significa
que Jarvis levanta cuando **vos iniciás sesión en Windows**, no cuando la
máquina prende. Si reiniciás y dejás la pantalla de login sin entrar, Jarvis no
arranca. Para que sobreviva reinicios solo, configurá inicio de sesión
automático en Windows.

**Suspensión.** Si el PC se suspende, Jarvis se suspende con él. En Configuración
→ Sistema → Inicio/apagado, poné suspensión en *Nunca*. Si es un portátil,
dejalo enchufado y revisá el comportamiento al cerrar la tapa.

**Apagá el gateway del contenedor** cuando el PC esté andando. Dos pollers sobre
el mismo token = 409 Conflict y el bot deja de responder:

```bash
pkill -f "[h]ermes gateway run"
```

**Saldo.** Nada de esto sirve con DeepSeek en cero: el proceso va a estar vivo y
cada mensaje va a fallar con `HTTP 402 Insufficient Balance`. Recargá primero en
https://platform.deepseek.com/top_up

**Si preferís apagarlo de noche.** Windows puede despertar solo con una tarea
programada que tenga *"Despertar el equipo para ejecutar esta tarea"* activado,
más el despertar por RTC habilitado en la BIOS. Telegram guarda los mensajes
~24 h, así que Jarvis contesta todo junto al despertar — con retraso, sin
perder nada.

## Actualizar

```powershell
cd Jarvis-IA
git pull
.\setup_jarvis.ps1
hermes gateway restart
```
