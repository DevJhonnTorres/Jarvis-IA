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

# API de Windows para fijar la resolucion del monitor virtual.
Add-Type -ErrorAction SilentlyContinue -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public class VDisp {
 [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
 public struct DEVMODE {
  [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmDeviceName;
  public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
  public int dmFields; public int dmPositionX, dmPositionY;
  public int dmDisplayOrientation, dmDisplayFixedOutput;
  public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
  [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmFormName;
  public short dmLogPixels; public int dmBitsPerPel, dmPelsWidth, dmPelsHeight;
  public int dmDisplayFlags, dmDisplayFrequency, dmICMMethod, dmICMIntent,
             dmMediaType, dmDitherType, dmReserved1, dmReserved2,
             dmPanningWidth, dmPanningHeight;
 }
 [DllImport("user32.dll")] public static extern bool EnumDisplaySettings(string dev, int mode, ref DEVMODE dm);
 [DllImport("user32.dll")] public static extern int ChangeDisplaySettingsEx(string dev, ref DEVMODE dm, IntPtr hwnd, int flags, IntPtr l);
}
'@

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

if ($ahora -lt 2) {
    Write-Host "[X] No se activo. Con la tapa cerrada AnyDesk va a dar pantalla negra." -ForegroundColor Red
    exit 1
}

# El monitor virtual nace en 1024x768, que es 4:3 y se ve cuadrado al lado de
# un panel 16:9. La lista de modos del driver NO incluye 1366x768, asi que el
# mas parecido es 1360x768: mismo 16:9, seis pixeles menos de ancho.
# La resolucion se fija por API y no por registro: reinstalar el nodo del
# driver reescribe esa clave con los valores del .inf y se pierde el cambio.
$virtual = [System.Windows.Forms.Screen]::AllScreens | Where-Object { -not $_.Primary } | Select-Object -First 1
if ($virtual -and $virtual.Bounds.Width -ne 1360) {
    $dm = New-Object VDisp+DEVMODE
    $dm.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($dm)
    if ([VDisp]::EnumDisplaySettings($virtual.DeviceName, -1, [ref]$dm)) {
        $dm.dmPelsWidth = 1360
        $dm.dmPelsHeight = 768
        $dm.dmFields = 0x80000 -bor 0x100000    # PELSWIDTH | PELSHEIGHT
        $r = [VDisp]::ChangeDisplaySettingsEx($virtual.DeviceName, [ref]$dm, [IntPtr]::Zero, 0, [IntPtr]::Zero)
        if ($r -eq 0) { Write-Host "     Resolucion ajustada a 1360x768" }
        else { Write-Host "     [!] No se pudo ajustar la resolucion (codigo $r)" -ForegroundColor Yellow }
        Start-Sleep -Seconds 3
    }
}

Write-Host "[OK] Monitor virtual activo. Pantallas: $ahora" -ForegroundColor Green
[System.Windows.Forms.Screen]::AllScreens | ForEach-Object {
    Write-Host ("     {0}  {1}x{2}  primaria: {3}" -f $_.DeviceName, $_.Bounds.Width, $_.Bounds.Height, $_.Primary)
}
exit 0
