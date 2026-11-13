#!/usr/bin/env bash
# Equivalente de preparar.ps1 para macOS/Linux (necesario para compilar iPhone).
set -e
[ -f pubspec.yaml ] || { echo "ERROR: ejecuta esto dentro de la carpeta con pubspec.yaml"; exit 1; }
rm -rf android ios
flutter create --org com.example --project-name staylink --platforms android,ios .
[ -f android/app/src/main/res/values/styles.xml ] || { echo "ERROR: faltan recursos de android/res"; exit 1; }
flutter pub get
python3 - <<'PY'
import re
m="android/app/src/main/AndroidManifest.xml"
t=open(m,encoding="utf-8").read()
t=re.sub(r'(<application[^>]*?android:label=")[^"]*(")',r'\1STAYLINK\2',t)
if 'android:scheme="tel"' not in t:
    it='<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent><intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>'
    if '<queries>' in t: t=t.replace('<queries>','<queries>\n        '+it,1)
    else: t=t.replace('<application','<queries>\n        '+it+'\n    </queries>\n    <application',1)
open(m,"w",encoding="utf-8").write(t)
p="ios/Runner/Info.plist"
t=open(p,encoding="utf-8").read()
t=re.sub(r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*',r'\1STAYLINK',t)
if 'NSPhotoLibraryUsageDescription' not in t:
    b="\t<key>NSPhotoLibraryUsageDescription</key>\n\t<string>Para elegir fotos de tu lugar.</string>\n\t<key>NSCameraUsageDescription</key>\n\t<string>Para tomar fotos de tu lugar.</string>\n"
    i=t.rindex('</dict>'); t=t[:i]+b+t[i:]
open(p,"w",encoding="utf-8").write(t)
PY
echo "Listo. Ahora: flutter run"
