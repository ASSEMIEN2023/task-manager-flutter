# Assets – Icônes et Splash Screen

Pour générer les vraies icônes et le splash screen :

## 1. Prépare deux images

- `assets/icon.png` → carré 1024x1024 px
- `assets/splash.png` → logo centré

Puis lance :
```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
