---
name: bateria
description: Estado de la bateria del equipo que hospeda a Jarvis (carga, si esta enchufado, autonomia). Usar cuando pregunten por bateria, cargador, energia o cuanto aguanta el equipo.
version: 1.0.0
author: jhonn
license: MIT
platforms: [windows]
prerequisites:
  commands: [powershell]
---

# Bateria del equipo de Jarvis

Jarvis corre en un portatil HP 14-cf2xxx con Windows. Si la bateria se agota,
el gateway muere y el bot queda mudo hasta que alguien encienda la maquina.
Por eso el estado de la bateria es informacion operativa, no un dato de color.

## Consultar el estado

Un solo comando, sin dependencias:

```powershell
Get-CimInstance Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus, EstimatedRunTime
```

Como interpretar `BatteryStatus`:

| Valor | Significa |
|---|---|
| 1 | Descargando (SIN cargador) |
| 2 | Conectado a la red electrica |
| 3-11 | Cargando o en mantenimiento; siempre con AC presente |

Regla practica: **enchufado = `BatteryStatus` distinto de 1**. No alcanza con
comparar contra 2, porque mientras carga devuelve otros valores.

`EstimatedRunTime` viene en minutos y solo es fiable descargando; enchufado
devuelve un numero enorme (71582788) que NO hay que reportar como autonomia.

## Mandar un reporte al chat

```powershell
& "$env:USERPROFILE\Jarvis-IA\battery_monitor.ps1" -Reporte
```

## Alertas automaticas (ya configuradas)

La tarea programada `Jarvis_Bateria` corre cada 5 minutos y avisa sola:

- Se desconecta o se reconecta el cargador
- Carga <= 40% (aviso)
- Carga <= 20% (critico)

No repite la misma alerta: guarda el estado en
`%LOCALAPPDATA%\hermes\battery_monitor_state.json` y solo la rearma cuando la
carga se recupera 5 puntos por encima del umbral. Si preguntan por que no
llego una alerta esperada, ese archivo es el primer lugar donde mirar.

Esas alertas NO pasan por el modelo: el script habla directo con la API de
Telegram, asi que no gastan creditos.

## Al responder

Se conciso: carga, si esta enchufado y, si esta descargando, la autonomia
estimada. Si esta por debajo de 20% sin cargador, decilo de entrada — es el
caso en que Jarvis esta por apagarse.
