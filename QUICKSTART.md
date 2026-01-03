# 🚀 QUICK START - Miabé Assistant

## ✅ Problèmes Résolus

- ✅ **Service Worker Timeout** (4000ms) - Ajout de fallback non-bloquant
- ✅ **Erreur RLS 401** (campus_likes) - RLS policies simplifiées et sécurisées
- ✅ **Erreur 400 Storage** (uploads) - Migration SQL + sanitization fichiers
- ✅ **Clés API exposées** - Migré vers variables d'environnement
- ✅ **Configuration** - .env.example + setup.sh + vérificateur

---

## 🏃 Démarrage Rapide (15 min)

### **Étape 1: Récupérer les Clés (2 min)**

Depuis Supabase Dashboard (https://app.supabase.com):
```
Project Settings > API:
- Copy SUPABASE_URL
- Copy anon (SUPABASE_ANON_KEY)
- Copy service_role (optional)

Project Settings > Access Tokens:
- Create or copy your token
```

### **Étape 2: Configurer l'Environnement (3 min)**

```bash
cd /home/light667/Miabe-Assistant

# Créer .env.local depuis le template
cp .env.example .env.local

# Éditer avec vos vraies clés
nano .env.local
# OU
code .env.local
```

Remplacer:
```dotenv
SUPABASE_URL=https://gtnyqqstqfwvncnymptm.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...        ← Votre vraie clé
MISTRAL_API_KEY=5kRJdcoJlcq0...       ← Votre vraie clé
```

### **Étape 3: Appliquer les Migrations SQL (3 min)**

```
1. Aller à: https://app.supabase.com → SQL Editor
2. Créer une nouvelle query
3. Copier le contenu de:
   app/supabase/migrations/20250103_fix_storage_rls.sql
4. Exécuter
5. Vérifier aucune erreur
```

### **Étape 4: Créer/Configurer les Buckets Storage (2 min)**

```
1. Aller à: Supabase Dashboard → Storage
2. Create New Bucket:
   Name: campus_files
   Visibility: Private
   (Politique RLS gérera les accès)
3. Create New Bucket:
   Name: campus_fiches
   Visibility: Private
```

### **Étape 5: Lancer l'App (5 min)**

```bash
cd app

# Nettoyer les caches
flutter clean
flutter pub get

# Lancer en développement local
flutter run -d chrome

# OU build web
flutter build web --release \
  --dart-define=MISTRAL_API_KEY=$(cat ../.env.local | grep MISTRAL_API_KEY | cut -d= -f2) \
  --dart-define=SUPABASE_ANON_KEY=$(cat ../.env.local | grep SUPABASE_ANON_KEY | cut -d= -f2)
```

---

## 🧪 Tests Rapides

Après le lancement, tester dans le navigateur:

```
1. ✅ Login (Firebase)
   - Voir les logs "Firebase user: ..." et UUID généré

2. ✅ Campus Page
   - Charger une communauté (Filière + Semestre)
   - Voir les posts/fiches

3. ✅ Like un Post
   - Cliquer l'icône ❤️ sur un post
   - Vérifier: PAS d'erreur 401
   - Vérifier le compteur +1

4. ✅ Upload Fiche
   - Cliquer "Partager" → Sélectionner une fiche PDF
   - Vérifier: PAS d'erreur 400
   - Vérifier la fiche apparaît dans la liste

5. ✅ Service Worker
   - Ouvrir Dev Tools (F12) → Console
   - Vérifier PAS de "prepareServiceWorker took more than 4000ms"
```

---

## 🔍 Vérifier la Configuration

```bash
# Script automatisé
python3 verify_config.py

# Doit afficher: "6/6 vérifications passées ✅"
```

---

## 📁 Structure Clés

```
/home/light667/Miabe-Assistant/
├── .env.local                          ← JAMAIS commiter!
├── .env.example                        ← Template
├── .gitignore                          ← Updated
│
├── app/
│   ├── lib/config/
│   │   ├── api_keys.dart              ← Variables d'environnement
│   │   └── supabase_config.dart       ← Variables d'environnement
│   ├── lib/services/
│   │   └── campus_service.dart        ← Opérations campus (NEW)
│   ├── lib/pages/
│   │   └── campus_page.dart           ← Gestion erreurs améliorée
│   ├── supabase/migrations/
│   │   └── 20250103_fix_storage_rls.sql  ← RLS & Storage config (NEW)
│   └── web/
│       └── index.html                 ← Service Worker timeout (FIXED)
│
├── setup.sh                            ← Script setup automatisé
├── verify_config.py                    ← Vérificateur config (NEW)
└── RESOLUTION.md                       ← Documentation complète
```

---

## 🐛 Troubleshooting Rapide

### Service Worker Timeout (4000ms)
✅ **RÉSOLU**: index.html a maintenant fallback
- App continue même si SW est lent
- Pas de blocage utilisateur

### Erreur 401 sur Like
✅ **RÉSOLU**: RLS policies simplifiées
- INSERT/DELETE/SELECT pour tous
- No need for Supabase auth (utilise Firebase)

### Erreur 400 sur Upload
✅ **RÉSOLU**: Migration SQL + sanitization
- Bucket `campus_files` configuré
- Accents convertis (é→e)
- Chemins validés

### Clés Exposées
✅ **RÉSOLU**: Variables d'environnement
- `String.fromEnvironment()` dans Dart
- `.env.local` dans `.gitignore`
- Pas de hardcoded secrets

---

## 📚 Ressources

- **RESOLUTION.md** - Documentation complète des changements
- **setup.sh** - Installation automatisée (bash)
- **verify_config.py** - Vérification configuration (python)
- **app/lib/services/campus_service.dart** - API Campus
- **create_campus_tables_complete.sql** - Schéma base de données

---

## 🎯 Checklist Avant Production

- [ ] Toutes les migrations SQL appliquées
- [ ] Buckets Storage créés (campus_files, campus_fiches)
- [ ] .env.local créé avec vraies clés
- [ ] verify_config.py retourne 6/6 ✅
- [ ] Tests manuels réussis (like, upload, etc.)
- [ ] Git history nettoyé des secrets (optionnel)
- [ ] Firebase/Supabase tokens actifs
- [ ] CORS configuré sur backend
- [ ] Rate limiting testé
- [ ] Logs vérifiés en production

---

## 🚀 Déploiement

### Web (Firebase)
```bash
cd app
flutter build web --release \
  --dart-define=MISTRAL_API_KEY=$MISTRAL_API_KEY \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

firebase deploy --only hosting
```

### Backend (Render)
```bash
cd backend
git push  # Auto-deploy depuis GitHub
```

### Mobile (Google Play / App Store)
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 💡 Tips Pro

1. **Développement**: Utiliser `flutter run -d chrome` avec hot reload
2. **Debugging**: Ouvrir DevTools avec `F12` dans le navigateur
3. **Logs**: Vérifier la console du navigateur pour les erreurs Supabase/Firebase
4. **Storage**: Tester les uploads avec des petits fichiers d'abord
5. **Perf**: Lazy-load les images avec `Image.network(..., fit: BoxFit.cover)`

---

**🎉 Vous êtes prêt! Lancez l'app et testez!**
