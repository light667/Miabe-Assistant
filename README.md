# 🎓 Miabe Assistant

> **Ton compagnon pour réussir tes études supérieures**

Application mobile et web dédiée à la réussite des étudiants togolais de l'enseignement supérieur. Miabe Assistant offre un chatbot intelligent, des ressources pédagogiques et des outils d'organisation pour faciliter votre parcours académique.

[![Déploiement Backend](https://img.shields.io/badge/Backend-Live-success?style=for-the-badge&logo=render)](https://miabe-assistant.onrender.com)
[![Déploiement Web](https://img.shields.io/badge/Web-Live-blue?style=for-the-badge&logo=firebase)](https://polyassistant-d250a.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18-339933?style=for-the-badge&logo=node.js)](https://nodejs.org)

---

## 📱 Fonctionnalités

### 🤖 Chatbot Intelligent
- Assistant pédagogique alimenté par **Mistral AI**
- Aide personnalisée pour vos études
- Conseils méthodologiques et académiques
- Support en français

### 📚 Bibliothèque de Ressources
- **387 documents PDF** disponibles
- Organisés par semestre et matière
- Stockage cloud sécurisé (Supabase)
- Accès hors ligne (à venir)

### 🎯 6 Filières Supportées
1. Génie Civil
2. Génie Électrique
3. Génie Mécanique
4. IA & Big Data
5. Informatique & Systèmes
6. Logistique & Transport

### 📖 Tronc Commun
- Semestre 1: 11 matières (162 PDFs)
- Semestre 2: 13 matières (225 PDFs)

---

## 🏗️ Architecture

### Structure Monorepo

```
miabe-assistant/
├── app/                    # Application Flutter
│   ├── lib/               # Code source Dart
│   │   ├── config/       # Configuration (API, Supabase)
│   │   ├── pages/        # Écrans de l'application
│   │   ├── services/     # Services (Mistral, Resources)
│   │   ├── providers/    # State management
│   │   └── widgets/      # Composants réutilisables
│   ├── assets/           # Ressources (images, manifests)
│   └── web/              # Build web
│
├── backend/               # API Express.js
│   ├── server.js         # Serveur Node.js
│   ├── package.json      # Dépendances npm
│   └── Dockerfile        # Containerisation
│
├── resources/             # PDFs locaux (gitignored)
│   └── tronc_commun/     # 668MB de ressources
│
├── Dockerfile             # Build Docker pour Render
├── render.yaml           # Configuration déploiement
└── firebase.json         # Configuration hosting
```

### Stack Technique

**Frontend (Flutter)**
- Flutter 3.9.2 & Dart 3.9.2
- Firebase Auth + Google Sign-In
- Supabase Storage
- Provider (State Management)
- Flutter Markdown

**Backend (Node.js)**
- Express.js 4.18.2
- Mistral AI API
- Rate limiting & CORS
- Helmet.js (sécurité)
- Docker (containerisation)

**Cloud Infrastructure**
- **Render**: Backend API
- **Firebase**: Web hosting + Auth
- **Supabase**: Storage des PDFs
- **GitHub**: CI/CD automatique

---

## 🚀 Démarrage Rapide

### Prérequis

- Flutter SDK ≥ 3.9.2
- Node.js ≥ 18.0.0
- Git

### Installation

```bash
# Cloner le repository
git clone https://github.com/light667/Miabe-Assistant.git
cd Miabe-Assistant

# Installation de l'application Flutter
cd app
flutter pub get

# Installation du backend
cd ../backend
npm install
```

### Lancement en Local

**Application Web:**
```bash
cd app
flutter run -d web-server --web-port 8080
# Ouvrir http://localhost:8080
```

**Backend API:**
```bash
cd backend
node server.js
# API disponible sur http://localhost:3000
```

---

## 🌐 Déploiement

### Application Web (Firebase)

```bash
cd app
flutter build web --release
firebase deploy --only hosting
```

### Backend (Render)

Le déploiement est automatique via GitHub:
1. Push vers `main`
2. Render détecte les changements
3. Build Docker automatique
4. Déploiement sur https://miabe-assistant.onrender.com

### APK Android

```bash
cd app
flutter build apk --release
# APK généré dans: build/app/outputs/flutter-apk/
```

---

## 🔧 Configuration

### Variables d'Environnement

**Backend (`backend/.env`):**
```env
NODE_ENV=production
MISTRAL_API_KEY=votre_clé_mistral
PORT=3000
```

**Flutter (`app/lib/config/`):**
- `supabase_config.dart`: URL et clé Supabase
- `api_keys.dart`: Clés API (Mistral)
- `app_config.dart`: Configuration générale

### URLs de Production

| Service | URL | Description |
|---------|-----|-------------|
| **Web App** | https://polyassistant-d250a.web.app | Interface utilisateur |
| **API Backend** | https://miabe-assistant.onrender.com | API chatbot |
| **Health Check** | https://miabe-assistant.onrender.com/health | Status API |
| **Supabase Storage** | https://gtnyqqstqfwvncnymptm.supabase.co | PDFs |

---

## 📊 Statistiques

- **Code**: 27 fichiers Dart + 1 serveur Node.js
- **Ressources**: 387 PDFs (668 MB)
- **Optimisation**: 86% de réduction (4.6GB → 668MB)
- **Filières**: 6 départements
- **Matières**: 24 (11 S1 + 13 S2)
- **Déploiements**: 3 plateformes (Render, Firebase, Supabase)

---

## 🤝 Contribution

Les contributions sont les bienvenues! Pour contribuer:

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commit les changements (`git commit -m 'Ajout fonctionnalité'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👨‍💻 Auteur

**Light667**
- GitHub: [@light667](https://github.com/light667)
- Projet: [Miabe-Assistant](https://github.com/light667/Miabe-Assistant)

---

## 🙏 Remerciements

- **Mistral AI** pour l'API de chatbot
- **Supabase** pour le storage
- **Firebase** pour l'hébergement
- **Render** pour le déploiement backend
- Tous les contributeurs et utilisateurs

---

<div align="center">

**Fait avec ❤️ pour les étudiants togolais**

[🌐 Web App](https://polyassistant-d250a.web.app) • [🔗 API](https://miabe-assistant.onrender.com) • [📱 Mobile](https://github.com/light667/Miabe-Assistant/releases)

</div>
