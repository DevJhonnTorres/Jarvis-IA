# Monitor de bateria con alertas por Telegram.
#
# Avisa cuando el portatil se desenchufa, cuando baja de 40% y cuando baja de
# 20%. Pensado para el equipo que hospeda a Jarvis: si la bateria se agota, el
# gateway muere y el bot queda mudo hasta que alguien encienda la maquina.
#
# NO consume creditos de DeepSeek: habla directo con la API de Telegram, sin
# pasar por el modelo. Corre cada 5 minutos como tarea programada.
#
# Uso manual:
#   .\battery_monitor.ps1            # revisa y alerta si corresponde
#   .\battery_monitor.ps1 -Reporte   # manda el estado actual siempre

param([switch]$Reporte)

$ErrorActionPreference = "Stop"

$HermesHome = if ($env:HERMES_HOME) { $env:HERMES_HOME } else { Join-Path $env:LOCALAPPDATA "hermes" }
$EnvFile    = Join-Path $HermesHome ".env"
$StateFile  = Join-Path $HermesHome "battery_monitor_state.json"

$UMBRAL_AVISO  = 40
$UMBRAL_CRITICO = 20

# --- Credenciales: unica fuente de verdad es el .env de Hermes -------------
function Get-EnvValue($Key) {
    if (-not (Test-Path $EnvFile)) { return $null }
    $line = Get-Content $EnvFile -Encoding UTF8 | Where-Object { $_ -match "^$Key=" } | Select-Object -First 1
    if ($line) { ($line -split '=', 2)[1].Trim() } else { $null }
}

$Token  = Get-EnvValue "TELEGRAM_BOT_TOKEN"
$ChatId = (Get-EnvValue "TELEGRAM_ALLOWED_USERS") -split ',' | Select-Object -First 1

if (-not $Token -or -not $ChatId) {
    Write-Error "Faltan TELEGRAM_BOT_TOKEN o TELEGRAM_ALLOWED_USERS en $EnvFile"
    exit 1
}

function Send-Telegram($Texto) {
    try {
        $body = @{ chat_id = $ChatId; text = $Texto; parse_mode = "Markdown" }
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/sendMessage" `
            -Method Post -Body $body -TimeoutSec 20 | Out-Null
        return $true
    } catch {
        Write-Warning "No se pudo enviar a Telegram: $($_.Exception.Message)"
        return $false
    }
}

# --- Lectura de la bateria -------------------------------------------------
$bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
if (-not $bat) {
    Write-Output "Sin bateria: este equipo es de escritorio, nada que monitorear."
    exit 0
}

$carga = [int]$bat.EstimatedChargeRemaining
# BatteryStatus 2 = conectado a la red electrica. 1 = descargando.
# El resto (3..11) son estados de carga/mantenimiento, todos con AC presente.
$enchufado = ($bat.BatteryStatus -ne 1)

# --- Estado previo, para no repetir la misma alerta cada 5 minutos ---------
$estado = @{ ultimoEnchufado = $null; avisoDado = $false; criticoDado = $false; llenoDado = $false }
if (Test-Path $StateFile) {
    try {
        $prev = Get-Content $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($k in @('ultimoEnchufado','avisoDado','criticoDado','llenoDado')) {
            if ($null -ne $prev.$k) { $estado[$k] = $prev.$k }
        }
    } catch { }
}

$icono = if ($enchufado) { "🔌" } else { "🔋" }
$modo  = if ($enchufado) { "enchufado" } else { "en bateria" }

# --- Reporte a pedido ------------------------------------------------------
if ($Reporte) {
    Send-Telegram "$icono *Bateria de Jarvis*`n`nCarga: *$carga%*`nEstado: $modo" | Out-Null
    Write-Output "Reporte enviado: $carga% ($modo)"
}

# --- Alertas ---------------------------------------------------------------
$mensajes = @()

# Cambio de enchufado <-> bateria
if ($null -ne $estado.ultimoEnchufado -and $estado.ultimoEnchufado -ne $enchufado) {
    if ($enchufado) {
        $mensajes += "🔌 *Cargador conectado*`n`nCarga: $carga%`nJarvis fuera de riesgo."
    } else {
        $mensajes += "⚠️ *Se desconecto el cargador*`n`nCarga: $carga%`nSi la bateria se agota, Jarvis se apaga."
    }
}

if ($enchufado) {
    # Carga completa: avisar para poder desconectar. Dejar el portatil clavado
    # en 100% enchufado es lo que mas envejece la bateria, y este modelo no
    # tiene limitador de carga en la BIOS (lo verificamos: la 14-cf de consumo
    # no trae Battery Health Manager), asi que el corte es manual.
    #
    # El umbral es 99 y no 100 a proposito: muchos portatiles se quedan en 99%
    # un buen rato antes de marcar 100, y algunos no lo marcan nunca.
    if ($carga -ge 99 -and -not $estado.llenoDado) {
        $mensajes += "✅ *Bateria al $carga%*`n`nYa podes desconectar el cargador.`nDejarlo enchufado al 100% todo el dia desgasta la bateria."
        $estado.llenoDado = $true
    }
}

if (-not $enchufado) {
    if ($carga -le $UMBRAL_CRITICO -and -not $estado.criticoDado) {
        $mensajes += "🚨 *BATERIA CRITICA: $carga%*`n`nConecta el cargador YA.`nCuando se apague, Jarvis no vuelve solo."
        $estado.criticoDado = $true
        $estado.avisoDado = $true
    }
    elseif ($carga -le $UMBRAL_AVISO -and -not $estado.avisoDado) {
        $mensajes += "⚠️ *Bateria en $carga%*`n`nConvendria enchufar el equipo.`nProxima alerta al $UMBRAL_CRITICO%."
        $estado.avisoDado = $true
    }
}

# Rearmar los avisos cuando se recupera, con histeresis de 5 puntos para que
# no oscile enviando alertas si la carga queda justo en el umbral.
if ($enchufado -or $carga -gt ($UMBRAL_AVISO + 5)) { $estado.avisoDado = $false }
if ($enchufado -or $carga -gt ($UMBRAL_CRITICO + 5)) { $estado.criticoDado = $false }
# El aviso de carga completa se rearma al desenchufar o al bajar de 95, para
# que no vuelva a sonar si la carga oscila entre 99 y 100 estando conectado.
if (-not $enchufado -or $carga -lt 95) { $estado.llenoDado = $false }

$estado.ultimoEnchufado = $enchufado

foreach ($m in $mensajes) { Send-Telegram $m | Out-Null }

$estado | ConvertTo-Json | Set-Content $StateFile -Encoding UTF8

$resumen = "$carga% - $modo"
if ($mensajes.Count -gt 0) { $resumen += " - $($mensajes.Count) alerta(s) enviada(s)" }
Write-Output $resumen
