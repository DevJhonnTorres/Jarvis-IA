# Registra la tarea programada que corre battery_monitor.ps1 cada 5 minutos.
#
# Existe como script aparte para poder reinstalarla sin rehacer todo el setup,
# y porque tiene dos sutilezas que es facil equivocar (y yo equivoque):
#
#   1. Una repeticion colgada de un disparador "al iniciar sesion" NO se arma
#      hasta que ocurre un inicio de sesion. Si registras la tarea con la
#      sesion ya abierta, queda con NextRunTime vacio y no corre nunca.
#      Por eso van DOS disparadores: uno por tiempo (arranca ya) y otro al
#      iniciar sesion (para que reviva tras un reinicio).
#
#   2. Windows NO ejecuta tareas programadas cuando el equipo esta en bateria,
#      que es justo cuando este monitor tiene que funcionar. De ahi
#      -AllowStartIfOnBatteries y -DontStopIfGoingOnBatteries.
#
# Uso:  .\install_battery_task.ps1

$ErrorActionPreference = "Stop"

$script = Join-Path $PSScriptRoot "battery_monitor.ps1"
if (-not (Test-Path $script)) {
    Write-Host "[X] No encuentro battery_monitor.ps1 junto a este script" -ForegroundColor Red
    exit 1
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""

$tTiempo = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Days 3650)   # TimeSpan::MaxValue lo rechaza Windows

$tLogon = New-ScheduledTaskTrigger -AtLogOn
$tLogon.Repetition = $tTiempo.Repetition

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName "Jarvis_Bateria" -Action $action `
    -Trigger @($tTiempo, $tLogon) -Settings $settings `
    -Description "Alertas de bateria de Jarvis por Telegram" -Force | Out-Null

$info = Get-ScheduledTaskInfo -TaskName "Jarvis_Bateria"

Write-Host ""
Write-Host "[OK] Tarea Jarvis_Bateria registrada" -ForegroundColor Green
Write-Host "     Proxima ejecucion: $($info.NextRunTime)"

# Si esto sale vacio, la repeticion no quedo armada y el monitor no va a correr.
if (-not $info.NextRunTime) {
    Write-Host "[!] ADVERTENCIA: sin proxima ejecucion, la tarea no va a dispararse sola." -ForegroundColor Yellow
    exit 1
}
