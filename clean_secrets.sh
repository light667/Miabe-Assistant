#!/bin/bash

# ============================================
# Git Secret Cleanup Helper
# ============================================
# Aide à nettoyer les secrets de l'historique Git
# ATTENTION: Cela modifiera l'historique!

set -e

echo "🔐 Git Secret Cleanup Helper"
echo "=============================="
echo ""
echo "⚠️  ATTENTION: Cette opération modifiera votre historique Git!"
echo "   Assurez-vous que:"
echo "   1. Vous avez une sauvegarde (git clone)"
echo "   2. Les autres contributeurs sont informés"
echo "   3. Vous avez sync de force après: git push --force"
echo ""

read -p "Continuer? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Annulé."
    exit 0
fi

# 1. Chercher les secrets potentiels
echo ""
echo "🔍 Scanning pour secrets potentiels..."
echo ""

SECRETS_FOUND=0

# Motifs de secrets courants
PATTERNS=(
    "eyJhbGciOiJIUzI1NiIs"  # JWT Supabase
    "5kRJdcoJlcq0"           # Mistral Key (exemple)
    "AIzaSy"                 # Firebase key pattern
    "AKIA"                   # AWS key pattern
)

for pattern in "${PATTERNS[@]}"; do
    count=$(git log -p --all -S "$pattern" | grep -c "^commit" || true)
    if [ "$count" -gt 0 ]; then
        echo "⚠️  Pattern '$pattern' trouvé dans $count commits"
        SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
done

if [ "$SECRETS_FOUND" -eq 0 ]; then
    echo "✅ Aucun secret trouvé dans l'historique"
    echo ""
    echo "Recommandations:"
    echo "  1. Assurez-vous que .env.local est dans .gitignore"
    echo "  2. Assurez-vous que api_keys.dart est dans .gitignore"
    echo "  3. Testez: git status (ne doit pas afficher ces fichiers)"
    exit 0
fi

echo ""
echo "❌ Secrets trouvés dans l'historique!"
echo ""
echo "Options de nettoyage:"
echo "  1. Utiliser BFG Repo-Cleaner (recommandé)"
echo "  2. Utiliser git filter-branch (plus lent)"
echo "  3. Manuel (pénible)"
echo ""
echo "BFG Repo-Cleaner:"
echo "  # Installer: brew install bfg  (ou apt-get install bfg)"
echo "  bfg --replace-text secrets.txt"
echo ""

echo "Notes importantes:"
echo "  • Les credentials DOIVENT être régénérées (on ne sait pas qui les a vues)"
echo "  • Notifier tous les contributeurs de faire git pull --rebase"
echo "  • Après push: notifier Supabase/Firebase pour revoquer les anciennes clés"
echo ""

# 2. Vérifier .gitignore
echo ""
echo "🔍 Vérification .gitignore..."

if grep -q "\.env\.local" .gitignore; then
    echo "✅ .env.local dans .gitignore"
else
    echo "❌ .env.local PAS dans .gitignore"
    echo "   Ajoutant..."
    echo ".env.local" >> .gitignore
fi

if grep -q "api_keys\.dart" .gitignore; then
    echo "✅ api_keys.dart dans .gitignore"
else
    echo "❌ api_keys.dart PAS dans .gitignore"
    echo "   Ajoutant..."
    echo "app/lib/config/api_keys.dart" >> .gitignore
fi

# 3. Test: fichiers non-tracked
echo ""
echo "🔍 Vérification fichiers non-tracked..."

UNTRACKED=$(git ls-files --others --exclude-standard)
if echo "$UNTRACKED" | grep -E "\.env\.local|api_keys\.dart|google-services\.json"; then
    echo "⚠️  Fichiers sensibles non-tracked (ignorés correctement)"
else
    echo "✅ Pas de fichiers sensibles visibles"
fi

echo ""
echo "✅ Vérifications terminées!"
echo ""
echo "Prochaines étapes:"
echo "  1. Régénérez toutes les clés API"
echo "  2. Si secrets en historique: utilisez BFG"
echo "  3. Testez: git status (filtrer les fichiers sensibles)"
echo "  4. Commitez les changements .gitignore"
echo ""
