# Prepara las carpetas android/ e ios/ con las PLANTILLAS OFICIALES de TU versión de Flutter
# y aplica la configuración de STAYLINK (nombre, permisos de enlaces/llamadas, ícono).
# Uso (PowerShell, dentro de la carpeta que contiene pubspec.yaml):  .\preparar.ps1
$ErrorActionPreference = "Stop"

if (-not (Test-Path "pubspec.yaml")) {
  Write-Host "ERROR: abre PowerShell dentro de la carpeta que contiene pubspec.yaml" -ForegroundColor Red
  exit 1
}

Write-Host "1/3 Generando android/ e ios/ con tu Flutter (se borran las anteriores)..." -ForegroundColor Cyan
if (Test-Path "android") { Remove-Item -Recurse -Force "android" }
if (Test-Path "ios") { Remove-Item -Recurse -Force "ios" }
flutter create --org com.example --project-name staylink --platforms android,ios .

$res = "android/app/src/main/res"
if (-not (Test-Path "$res/values/styles.xml") -or -not (Test-Path "$res/mipmap-mdpi/ic_launcher.png")) {
  Write-Host "ERROR: flutter create no genero android/app/src/main/res. Copia el texto de error de arriba y envialo." -ForegroundColor Red
  exit 1
}
Write-Host "Recursos de Android OK." -ForegroundColor Green

Write-Host "2/3 Instalando paquetes..." -ForegroundColor Cyan
flutter pub get


Write-Host "3/3 Configurando nombre y permisos de enlaces..." -ForegroundColor Cyan
$utf8 = New-Object System.Text.UTF8Encoding $false

# ---- Android: nombre visible + <queries> (necesario para abrir https y marcar tel:) ----
$m = Join-Path $PWD "android/app/src/main/AndroidManifest.xml"
$t = [System.IO.File]::ReadAllText($m)
$t = [regex]::Replace($t, '(<application[^>]*?android:label=")[^"]*(")', '${1}STAYLINK${2}')
if ($t -notmatch 'android:scheme="tel"') {
  $intents = '<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>' +
             '<intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>'
  if ($t -match '<queries>') {
    $t = $t.Replace('<queries>', "<queries>`n        $intents")
  } else {
    $t = $t.Replace('<application', "<queries>`n        $intents`n    </queries>`n    <application")
  }
}
[System.IO.File]::WriteAllText($m, $t, $utf8)

# ---- iPhone: nombre visible + esquemas permitidos ----
$p = Join-Path $PWD "ios/Runner/Info.plist"
$t = [System.IO.File]::ReadAllText($p)
$t = [regex]::Replace($t, '(<key>CFBundleDisplayName</key>\s*<string>)[^<]*', '${1}STAYLINK')
if ($t -notmatch 'NSPhotoLibraryUsageDescription') {
  $bloque = "`t<key>NSPhotoLibraryUsageDescription</key>`n`t<string>Para elegir fotos de tu lugar.</string>`n`t<key>NSCameraUsageDescription</key>`n`t<string>Para tomar fotos de tu lugar.</string>`n"
  $idx = $t.LastIndexOf('</dict>')
  $t = $t.Insert($idx, $bloque)
}
[System.IO.File]::WriteAllText($p, $t, $utf8)

Write-Host ""
Write-Host "Listo. Ahora ejecuta:  flutter run" -ForegroundColor Green
