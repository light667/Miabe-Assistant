# 🛠️ COMMANDES IMPORTANTES

## 🚀 Démarrage

```bash
# 1. Configuration initiale
cd /home/light667/Miabe-Assistant
cp .env.example .env.local
nano .env.local  # Éditer avec vraies clés

# 2. Vérifier config
python3 verify_config.py

# 3. Installer dépendances Flutter
cd app
flutter clean
flutter pub get

# 4. Lancer l'app
flutter run -d chrome
```

---

## 🔨 Build & Deployment

### Web (Flutter)
```bash
# Development (avec hot reload)
flutter run -d chrome

# Build release
flutter build web --release \
  --dart-define=MISTRAL_API_KEY=$MISTRAL_API_KEY \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Déployer sur Firebase
firebase deploy --only hosting
```

### Mobile Android
```bash
flutter build apk --release
# OU AAB pour Play Store
flutter build appbundle --release
```

### Mobile iOS
```bash
flutter build ios --release
flutter build ipa --release
```

### Backend (Node)
```bash
cd backend
npm install
npm start

# Pour Render: commit & push
git push origin main  # Auto-deploy
```

---

## 🗄️ Base de Données

### Appliquer migrations
```bash
# Via CLI Supabase
supabase db push

# OU manuellement:
# 1. Aller: https://app.supabase.com/project/*/sql/new
# 2. Copy: app/supabase/migrations/*.sql
# 3. Exécuter
```

### Vérifier l'état
```bash
# Supabase CLI
supabase status

# OU Query dans SQL Editor:
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public';
```

### Nettoyer données test
```sql
-- ATTENTION: DELETE tout!
TRUNCATE TABLE campus_posts CASCADE;
TRUNCATE TABLE campus_comments CASCADE;
TRUNCATE TABLE campus_fiches CASCADE;
TRUNCATE TABLE campus_likes CASCADE;
TRUNCATE TABLE campus_members CASCADE;
```

---

## 🔐 Gestion des Secrets

### Créer .env.local
```bash
cp .env.example .env.local
cat .env.local  # Vérifier le contenu
git status      # Ne doit PAS afficher .env.local
```

### Vérifier les secrets en Git
```bash
# Chercher JWT patterns
git log -p --all | grep -i "eyJhbGci"

# Chercher API keys
git log -p --all | grep -i "api_key"

# Si trouvé: utiliser clean_secrets.sh
bash clean_secrets.sh
```

### Régénérer les clés
```bash
# Supabase
# 1. Project Settings > API
# 2. Regenerate anon key
# 3. Regenerate service role key

# Mistral AI
# 1. https://console.mistral.ai/
# 2. API Keys > Create new key

# Firebase
# 1. https://console.firebase.google.com/
# 2. Project Settings > Service Accounts
# 3. Generate new key
```

---

## 🧪 Tests

### Tests unitaires
```bash
cd app
flutter test
flutter test --coverage
```

### Tests d'intégration
```bash
flutter test integration_test/
```

### Tests manuels
```bash
# 1. Login Firebase
# 2. Créer post
# 3. Like le post (vérifier pas d'erreur)
# 4. Upload fiche (vérifier pas d'erreur)
# 5. Vérifier logs console (F12)
```

### Vérifier les logs
```bash
# Flutter (terminal)
flutter run -d chrome -v

# Navigateur (F12)
# Console > Filtrer par source
```

---

## 🐛 Debugging

### Flutter DevTools
```bash
# Automatique avec flutter run
# Manual:
flutter pub global activate devtools
devtools

# Puis: flutter run --devtools-server-address=localhost:9100
```

### Supabase Logs
```bash
# Dashboard > Logs > Postgres Logs
# Dashboard > Logs > API Errors
# Dashboard > Logs > Storage Logs
```

### Firebase Logs
```bash
# https://console.firebase.google.com/ > Logs
# Firebase CLI:
firebase functions:log

# Debugger:
firebase emulators:start
```

---

## 📊 Monitoring

### Supabase
```bash
# Storage usage
supabase storage ls resources

# Database size
SELECT pg_size_pretty(pg_database_size('postgres'));

# RLS policies
SELECT * FROM pg_policies 
WHERE schemaname = 'public';
```

### Firebase
```bash
# Firebase CLI
firebase database:instances:list
firebase database:get /

# Functions
firebase functions:list
firebase functions:log
```

---

## 🚨 Emergency Commands

### Rollback DB
```bash
# Via migrations (meilleur)
supabase db reset

# OU via backup (lent)
# 1. Dashboard > Backups
# 2. Restore from backup
```

### Clear Storage
```bash
# Via CLI Supabase
supabase storage remove resources --recursive

# Via code (DANGEREUX!)
# Supabase.instance.storage.from('resources').removeAll();
```

### Force rebuild
```bash
flutter clean
rm -rf app/.dart_tool
rm -rf app/build
flutter pub get
flutter run -d chrome
```

### Kill stuck processes
```bash
# Flutter
pkill -f flutter

# Node
lsof -i :3000  # Voir le process
kill -9 <PID>

# Web server
pkill -f "python3 verify_config"
```

---

## 📱 Device Management

### Lister les devices
```bash
flutter devices
```

### Attacher un device
```bash
flutter devices --list
flutter run -d <device_id>
```

### Simulateurs
```bash
# Android
flutter emulators

# iOS
flutter run -d iPhone\ 13
```

---

## 📚 Documentation

### Générer docs
```bash
# Dart docs
dart doc

# API docs (site local)
pub global activate dartdoc
dartdoc

# Lancer le serveur
cd doc/api
python3 -m http.server
```

---

## 🔄 Git Workflows

### Feature branch
```bash
git checkout -b feature/campus-improvements
git commit -m "feat: améliorer campus page"
git push origin feature/campus-improvements
# => Créer PR sur GitHub
```

### Hotfix urgent
```bash
git checkout -b hotfix/fix-rls-error
git commit -m "fix: RLS policy for campus_likes"
git push origin hotfix/fix-rls-error
# => Merge to main via PR
```

### Sync fork
```bash
git remote add upstream https://github.com/original/repo.git
git fetch upstream
git rebase upstream/main
git push origin main --force-with-lease
```

---

## 🎯 Performance

### Profiling Flutter
```bash
flutter run -d chrome --profile
# DevTools > Timeline tab
```

### Analyzer
```bash
# Check code quality
flutter analyze

# Fix issues
flutter pub get
dart fix --apply
```

### Benchmarks
```bash
flutter run --release --trace-skia
# Généère benchmark.json
```

---

## 📞 Support Quick Links

```
Supabase Documentation:
https://supabase.com/docs

Flutter Documentation:
https://flutter.dev/docs

Firebase Documentation:
https://firebase.google.com/docs

Dart Language:
https://dart.dev/guides

Mistral AI:
https://docs.mistral.ai/
```

---

**💡 Tip**: Ajouter ces commandes à un alias bash dans `~/.bashrc`:

```bash
alias miabe-dev='cd /home/light667/Miabe-Assistant && code .'
alias miabe-run='cd /home/light667/Miabe-Assistant/app && flutter run -d chrome'
alias miabe-build='cd /home/light667/Miabe-Assistant/app && flutter build web --release'
```
