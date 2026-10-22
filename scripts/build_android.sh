#!/bin/bash
set -e
echo "🚀 Build Android APK (release)..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
echo ""
echo "✅ Build terminé !"
echo "Fichiers dans build/app/outputs/flutter-apk/"
