# Task Manager – Application Multiplateforme

Application de gestion de tâches personnelle disponible sur :
- **Android** (APK / AAB)
- **Web** (PWA)
- **Windows** (.exe)
- **macOS** (.dmg)

## Stack technique

- **Frontend** : Flutter 3.x (une seule codebase)
- **State management** : Riverpod
- **Backend** : Supabase (Auth + PostgreSQL + Realtime + Storage)

## Fonctionnalités

- Authentification (email + mot de passe)
- Création / modification / suppression de tâches
- Priorités (Basse, Moyenne, Haute, Urgente)
- Date d’échéance
- Mode clair / sombre automatique
- Synchronisation cloud

## Installation & Lancement

1. Configure tes clés Supabase dans `lib/core/constants/app_constants.dart`
2. Exécute les commandes SQL du README dans Supabase
3. Puis :

```bash
flutter create .
flutter pub get
flutter run
```

## Générer les fichiers installables

```bash
./scripts/build_android.sh   # APK
./scripts/build_windows.sh   # Windows
./scripts/build_macos.sh     # macOS + DMG
```

Ou utilise GitHub Actions (onglet Actions → Build Installers).

Voir le README complet dans le dépôt pour tous les détails.
