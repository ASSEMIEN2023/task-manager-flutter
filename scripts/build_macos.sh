#!/bin/bash
set -e
echo "🚀 Build macOS (release)..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi
flutter clean
flutter pub get
flutter build macos --release
echo ""
echo "✅ Build macOS terminé !"
echo "App : build/macos/Build/Products/Release/task_manager.app"
echo "Pour créer un .dmg : brew install create-dmg puis create-dmg ..."
