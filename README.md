# Task Manager – Application Multiplateforme

Application de gestion de tâches personnelle disponible sur :

| Plateforme | Format |
|------------|--------|
| **Android** | `.apk` / `.aab` |
| **Web** | PWA (installable) |
| **Windows** | `.exe` |
| **macOS** | `.dmg` / `.app` |

**Dépôt :** https://github.com/ASSEMIEN2023/task-manager-flutter

---

## Stack technique

- **Frontend** : Flutter 3.x (une seule codebase)
- **State management** : Riverpod
- **Backend** : Supabase (Auth + PostgreSQL + Realtime)
- **CI/CD** : GitHub Actions (build automatique APK + Windows + macOS + Web)

---

## Fonctionnalités

- Authentification (email + mot de passe)
- Création / modification / suppression de tâches
- Priorités colorées (Basse, Moyenne, Haute, Urgente)
- Date d’échéance
- Mode clair / sombre automatique
- Synchronisation cloud

---

## Démarrage rapide

### 1. Configurer Supabase

1. Crée un projet sur [supabase.com](https://supabase.com)
2. Dans **SQL Editor**, exécute :

```sql
create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  title text not null,
  description text,
  due_date timestamptz,
  priority text default 'Moyenne',
  category_id uuid,
  is_completed boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  name text not null,
  color int default 4280391413
);

alter table tasks enable row level security;
alter table categories enable row level security;

create policy "Users can manage their own tasks"
  on tasks for all using (auth.uid() = user_id);

create policy "Users can manage their own categories"
  on categories for all using (auth.uid() = user_id);
```

3. Copie l’**URL** et la clé **anon** dans :
   `lib/core/constants/app_constants.dart`

### 2. Lancer en local

```bash
git clone https://github.com/ASSEMIEN2023/task-manager-flutter.git
cd task-manager-flutter
flutter create .
flutter pub get
flutter run
```

---

## Générer les fichiers installables

### Avec GitHub Actions (recommandé)

1. Va dans l’onglet **Actions** du dépôt
2. Sélectionne **Build Installers**
3. Clique sur **Run workflow**
4. Télécharge les artefacts :
   - `android-apk` → fichier `.apk`
   - `windows-release` → version Windows
   - `macos-app` → application macOS
   - `web-pwa` → version Web

### En local

```bash
./scripts/build_android.sh   # APK Android
./scripts/build_windows.sh   # Windows
./scripts/build_macos.sh     # macOS
flutter build web --release  # Web / PWA
```

### Créer un vrai installateur Windows (.exe)

1. Build Windows
2. Installe [Inno Setup](https://jrsoftware.org/isinfo.php)
3. Ouvre `scripts/installer_windows.iss` et compile

---

## Déploiement Web (PWA)

Le workflow déploie automatiquement la version Web sur **GitHub Pages** à chaque push sur `main`.

Pour l’activer :
1. Va dans **Settings → Pages**
2. Source : **GitHub Actions**
3. L’URL sera : `https://assemi2023.github.io/task-manager-flutter/`

Tu peux aussi déployer sur **Vercel** ou **Netlify** en pointant vers le dossier `build/web`.

---

## Icônes + Splash Screen

```bash
# Place assets/icon.png (1024x1024) et assets/splash.png
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Signature APK

```bash
./scripts/generate_keystore.sh
```

Puis configure `android/app/build.gradle`.

**Ne commit jamais** le fichier `.jks` ni `key.properties`.

---

Généré et déployé par l’équipe d’Agents IA
