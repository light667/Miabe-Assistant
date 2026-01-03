#!/bin/bash

# ============================================
# Configuration Script - Miabé Assistant Setup
# ============================================
# Usage: ./setup.sh
# Description: Configure environment variables, build configs, etc.

set -e  # Exit on error

echo "🚀 Configuration Miabé Assistant"
echo "=================================="

# 1. Vérifier les fichiers .env
echo ""
echo "📝 Étape 1: Configuration Variables d'Environnement"

if [ -f ".env.local" ]; then
    echo "✅ .env.local existe"
else
    echo "⚠️  .env.local manquant - copie depuis .env.example"
    cp .env.example .env.local
    echo "📝 Remplissez .env.local avec vos vraies clés"
fi

# 2. Vérifier .gitignore
echo ""
echo "🔐 Étape 2: Vérification Sécurité Git"

if grep -q "\.env\.local" .gitignore; then
    echo "✅ .env.local dans .gitignore"
else
    echo "⚠️  Ajout de .env.local à .gitignore"
    echo ".env.local" >> .gitignore
fi

if grep -q "api_keys\.dart" .gitignore; then
    echo "✅ api_keys.dart dans .gitignore"
else
    echo "⚠️  Ajout de api_keys.dart à .gitignore"
    echo "app/lib/config/api_keys.dart" >> .gitignore
fi

# 3. Vérifier Flutter
echo ""
echo "✨ Étape 3: Vérification Flutter"

if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo "✅ Flutter installé: $FLUTTER_VERSION"
else
    echo "❌ Flutter non installé. Installez-le depuis https://flutter.dev"
    exit 1
fi

# 4. Nettoyer et télécharger dépendances
echo ""
echo "📦 Étape 4: Dépendances Flutter"

cd app
flutter clean
flutter pub get

echo "✅ Dépendances téléchargées"

# 5. Optionnel: Build web
echo ""
echo "🌐 Étape 5: Web Build (optionnel)"
read -p "Générer la version web? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Building web..."
    # Note: Utiliser les vraies clés via --dart-define
    # flutter build web --release \
    #     --dart-define=MISTRAL_API_KEY=your_key \
    #     --dart-define=SUPABASE_ANON_KEY=your_key
    
    echo "⚠️  Pour le build, utilisez:"
    echo "  flutter build web --release \\"
    echo "    --dart-define=MISTRAL_API_KEY=\$MISTRAL_API_KEY \\"
    echo "    --dart-define=SUPABASE_ANON_KEY=\$SUPABASE_ANON_KEY"
fi

# 6. Backend setup
echo ""
echo "🔧 Étape 6: Backend Configuration"

if [ -f "backend/package.json" ]; then
    cd ../backend
    npm install
    echo "✅ Backend dépendances installées"
    
    if [ -f ".env" ]; then
        echo "✅ .env backend existe"
    else
        echo "📝 Créez backend/.env avec:"
        echo "  MISTRAL_API_KEY=your_key"
        echo "  PORT=3000"
    fi
    cd ../app
fi

# 7. Résumé
echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "  1. Éditez .env.local avec vos vraies clés"
echo "  2. Exécutez: flutter run (ou flutter run -d chrome pour le web)"
echo "  3. Testez les opérations campus (posts, likes, uploads)"
echo ""
echo "🔒 Rappel de sécurité:"
echo "  - JAMAIS commiter .env.local ou api_keys.dart"
echo "  - Les clés sensibles doivent être dans des variables d'environnement"
echo "  - Pour production, utilisez Firebase Secret Manager ou similar"
echo ""
