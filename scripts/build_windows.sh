#!/bin/bash
set -e
echo "🚀 Build Windows (release)..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi
flutter clean
flutter pub get
flutter build windows --release
echo ""
echo "✅ Build Windows terminé !"
echo "Dossier : build/windows/x64/runner/Release/"
echo "Utilise scripts/installer_windows.iss avec Inno Setup pour créer le .exe"
