# Deja el PC listo para tener a Jarvis prendido 24/7.
#
# Correr DESPUES de:
#   iex (irm https://hermes-agent.nousresearch.com/install.ps1)
#   .\setup_jarvis.ps1
#   hermes gateway install --start-now --start-on-login
#
# Uso: PowerShell COMO ADMINISTRADOR
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\windows_always_on.ps1

$ErrorActionPreference = "Continue"

# --- Requiere admin: powercfg /hibernate falla sin elevacion ---------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[X] Abri PowerShell COMO ADMINISTRADOR y volve a correrlo" -ForegroundColor Red
    exit 1
}

Write-Host "=== 1. Energia: que no se duerma ===" -ForegroundColor Cyan
# Un PC suspendido = Jarvis suspendido. La pantalla SI puede apagarse: eso no
# suspende el equipo y ahorra energia.
powercfg /change standby-timeout-ac 0      # nunca suspender (enchufado)
powercfg /change hibernate-timeout-ac 0    # nunca hibernar
powercfg /change disk-timeout-ac 0         # no apagar discos
powercfg /hibernate off                    # libera hiberfil.sys

# Tambien en bateria: venia con 10 minutos, y un equipo suspendido corta
# AnyDesk y congela a Jarvis. Durante un corte de luz preferimos seguir
# accesibles y que las alertas de bateria avisen, antes que desaparecer.
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-dc 0

# Cerrar la tapa NO debe suspender: es la forma mas comun de matar sin querer
# un portatil que hace de servidor. 0 = no hacer nada, en AC y en bateria.
$subBotones = "4f971e89-eebd-4455-a8de-9e59040e7347"
$accionTapa = "5ca83367-6e45-459f-a27b-476b1d01c936"
powercfg /setacvalueindex SCHEME_CURRENT $subBotones $accionTapa 0
powercfg /setdcvalueindex SCHEME_CURRENT $subBotones $accionTapa 0
powercfg /setactive SCHEME_CURRENT

Write-Host "   suspension e hibernacion desactivadas (enchufado y en bateria)"
Write-Host "   cerrar la tapa: no hacer nada"
Write-Host "   la pantalla puede seguir apagandose, no afecta"

Write-Host ""
Write-Host "=== 2. Estado de la tarea del gateway ===" -ForegroundColor Cyan
$task = Get-ScheduledTask -ErrorAction SilentlyContinue |
        Where-Object { $_.TaskName -like "*ermes*" -or $_.TaskName -like "*arvis*" }

if ($task) {
    foreach ($t in $task) {
        Write-Host "   tarea: $($t.TaskName)  estado: $($t.State)"
        $triggers = $t.Triggers | ForEach-Object { $_.CimClass.CimClassName }
        Write-Host "   disparadores: $($triggers -join ', ')"
    }
} else {
    Write-Host "   [!] No encontre la tarea. Corriste 'hermes gateway install'?" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== 3. Inicio de sesion automatico ===" -ForegroundColor Cyan
# El instalador de Hermes registra la tarea con LogonTrigger + InteractiveToken:
# Jarvis arranca cuando VOS iniciás sesión, no cuando prende la maquina. Si
# Windows se reinicia solo de madrugada por una actualizacion y queda en la
# pantalla de login, Jarvis NO levanta hasta que alguien entre.
$autoLogon = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name AutoAdminLogon -ErrorAction SilentlyContinue).AutoAdminLogon

if ($autoLogon -eq "1") {
    Write-Host "   [OK] ya esta activado: sobrevive reinicios solo" -ForegroundColor Green
} else {
    Write-Host "   [!] DESACTIVADO — un reinicio desatendido deja a Jarvis abajo" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Para activarlo:"
    Write-Host "     1. Win+R  ->  netplwiz"
    Write-Host "     2. Destilda 'Los usuarios deben escribir su nombre y contrasena'"
    Write-Host "     3. Aplicar, y escribi tu contrasena cuando la pida"
    Write-Host ""
    Write-Host "   OJO: con esto, cualquiera que prenda el PC entra a tu sesion."
    Write-Host "   Si no te sirve, la alternativa es abrir la tarea en el"
    Write-Host "   Programador de tareas y marcar 'Ejecutar tanto si el usuario"
    Write-Host "   inicio sesion como si no'."
}

Write-Host ""
Write-Host "=== 4. Comprobacion final ===" -ForegroundColor Cyan
hermes gateway status

Write-Host ""
Write-Host "Pendiente manual (no se puede automatizar de forma confiable):" -ForegroundColor Yellow
Write-Host "  Administrador de dispositivos -> tu adaptador de red -> Propiedades"
Write-Host "  -> Administracion de energia -> DESTILDAR 'Permitir que el equipo"
Write-Host "  apague este dispositivo para ahorrar energia'."
Write-Host "  Sin eso, Windows puede apagarte la placa de red al rato."
Write-Host ""
Write-Host "Y lo mas importante: recarga DeepSeek, o Jarvis va a estar vivo"
Write-Host "respondiendo 'Insufficient Balance' a cada mensaje."
