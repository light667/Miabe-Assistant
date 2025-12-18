# Miabe Assistant

Application mobile et web pour les étudiants avec backend API.

## Structure

```
/app        - Application Flutter (Android, iOS, Web)
/backend    - API Express.js pour le chatbot
```

## Backend

### Déploiement
- Hébergé sur Render: https://miabe-assistant.onrender.com
- Auto-déployé depuis ce repo via Docker

### Développement local
```bash
cd backend
npm install
node server.js
```

## Application

### Web
- Déployé sur Firebase: https://polyassistant-d250a.web.app

### Build
```bash
cd app
flutter pub get
flutter build web --release
flutter build apk --release
```

## Configuration

### Supabase Storage
- URL: https://gtnyqqstqfwvncnymptm.supabase.co
- Bucket: resources (404 PDFs pour 6 filières)

### Firebase
- Hébergement web configuré
- Analytics et notifications push

### API Chatbot
- Mistral AI pour les réponses intelligentes
- Endpoint: https://miabe-assistant.onrender.com/api/chatbot
