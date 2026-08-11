# Activa el monitor virtual si no hay uno.
#
# Por que: el portatil tiene Intel UHD con una sola pantalla integrada. Al
# cerrar la tapa el panel se apaga, la GPU se queda sin display activo y
# AnyDesk muestra pantalla NEGRA aunque la maquina siga despierta y conectada.
# Ninguna opcion de energia lo arregla: no es que Windows suspenda, es que no
# queda nada que renderizar.
#
# El monitor virtual (usbmmidd, driver firmado por Microsoft Windows Hardware
# Compatibility Publisher) le da a la GPU una pantalla que nunca se apaga, asi
# que al cerrar la tapa Windows mueve el escritorio ahi y AnyDesk lo captura.
#
# El monitor virtual NO sobrevive un reinicio, por eso este script corre al
# arrancar. Es idempotente: si ya hay dos pantallas, no hace nada.
#
# Uso:  .\enable_virtual_display.ps1

$ErrorActionPreference = "Continue"

$dir = Join-Path $PSScriptRoot "tools\usbmmidd"
$exe = Join-Path $dir "deviceinstaller64.exe"

if (-not (Test-Path $exe)) {
    Write-Host "[X] Falta $exe" -ForegroundColor Red
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms

function Contar-Pantallas {
    ([System.Windows.Forms.Screen]::AllScreens).Count
}

$antes = Contar-Pantallas
Write-Host "Pantallas activas: $antes"

if ($antes -ge 2) {
    Write-Host "[OK] Ya hay un segundo monitor, no hay nada que hacer."
    exit 0
}

Write-Host "Solo una pantalla: activando el monitor virtual..."
Push-Location $dir
& $exe enableidd 1 | Out-Null
Pop-Location

# El dispositivo tarda unos segundos en aparecer como display.
$limite = (Get-Date).AddSeconds(30)
do {
    Start-Sleep -Seconds 3
    $ahora = Contar-Pantallas
} while ($ahora -lt 2 -and (Get-Date) -lt $limite)

if ($ahora -ge 2) {
    Write-Host "[OK] Monitor virtual activo. Pantallas: $ahora" -ForegroundColor Green
    [System.Windows.Forms.Screen]::AllScreens | ForEach-Object {
        Write-Host ("     {0}  {1}x{2}  primaria: {3}" -f $_.DeviceName, $_.Bounds.Width, $_.Bounds.Height, $_.Primary)
    }
    exit 0
} else {
    Write-Host "[X] No se activo. Con la tapa cerrada AnyDesk va a dar pantalla negra." -ForegroundColor Red
    exit 1
}
