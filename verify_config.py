#!/usr/bin/env python3
"""
Script de vérification de configuration - Miabé Assistant
Teste les connexions et configurations
"""

import os
import sys
from pathlib import Path

def check_env_files():
    """Vérifier les fichiers .env"""
    print("📝 Vérification fichiers d'environnement...\n")
    
    root = Path(__file__).parent
    
    # .env.example
    env_example = root / ".env.example"
    if env_example.exists():
        print(f"✅ {env_example} existe")
    else:
        print(f"❌ {env_example} manquant!")
        return False
    
    # .env.local (ne doit pas être commitée)
    env_local = root / ".env.local"
    if env_local.exists():
        print(f"✅ {env_local} existe (local)")
    else:
        print(f"⚠️  {env_local} manquant (créer depuis .env.example)")
    
    return True

def check_gitignore():
    """Vérifier que les fichiers sensibles sont dans .gitignore"""
    print("\n🔐 Vérification .gitignore...\n")
    
    gitignore = Path(".gitignore")
    if not gitignore.exists():
        print("❌ .gitignore manquant!")
        return False
    
    content = gitignore.read_text()
    
    patterns = [
        ".env.local",
        "api_keys.dart",
        "google-services.json",
    ]
    
    all_good = True
    for pattern in patterns:
        if pattern in content:
            print(f"✅ '{pattern}' dans .gitignore")
        else:
            print(f"⚠️  '{pattern}' PAS dans .gitignore")
            all_good = False
    
    return all_good

def check_dart_files():
    """Vérifier les fichiers Dart de config"""
    print("\n📱 Vérification configuration Dart...\n")
    
    root = Path("app/lib/config")
    
    api_keys = root / "api_keys.dart"
    if not api_keys.exists():
        print(f"❌ {api_keys} manquant!")
        return False
    
    content = api_keys.read_text()
    
    # Vérifier que les clés sont vides ou utilisent String.fromEnvironment
    if "String.fromEnvironment" in content:
        print(f"✅ {api_keys} utilise variables d'environnement")
    elif "defaultValue: ''" in content or "defaultValue: ''" in content:
        print(f"✅ {api_keys} a des valeurs par défaut vides")
    else:
        print(f"⚠️  {api_keys} peut contenir des hardcoded values")
    
    # Vérifier pas de vraies clés
    if any(secret in content for secret in ["5kRJdcoJlcq0LdxLEbhfY6kFEpVM6CJd", "eyJhbGci"]):
        print(f"🚨 DANGER: {api_keys} contient des clés hardcoded!")
        return False
    
    supabase_config = root / "supabase_config.dart"
    if not supabase_config.exists():
        print(f"❌ {supabase_config} manquant!")
        return False
    
    print(f"✅ {supabase_config} existe")
    
    return True

def check_migrations():
    """Vérifier les migrations SQL"""
    print("\n🗄️  Vérification migrations SQL...\n")
    
    migrations_dir = Path("app/supabase/migrations")
    if not migrations_dir.exists():
        print(f"❌ {migrations_dir} manquant!")
        return False
    
    migrations = list(migrations_dir.glob("*.sql"))
    if not migrations:
        print(f"⚠️  Aucune migration trouvée dans {migrations_dir}")
        return False
    
    print(f"✅ {len(migrations)} migrations trouvées:")
    for migration in sorted(migrations):
        print(f"   - {migration.name}")
    
    return True

def check_flutter_pubspec():
    """Vérifier pubspec.yaml"""
    print("\n📦 Vérification pubspec.yaml...\n")
    
    pubspec = Path("app/pubspec.yaml")
    if not pubspec.exists():
        print(f"❌ {pubspec} manquant!")
        return False
    
    content = pubspec.read_text()
    
    required_deps = [
        "supabase_flutter",
        "firebase_auth",
        "firebase_core",
    ]
    
    all_good = True
    for dep in required_deps:
        if dep in content:
            print(f"✅ {dep} présent")
        else:
            print(f"❌ {dep} MANQUANT!")
            all_good = False
    
    return all_good

def check_web_config():
    """Vérifier configuration web"""
    print("\n🌐 Vérification configuration web...\n")
    
    index_html = Path("app/web/index.html")
    if not index_html.exists():
        print(f"❌ {index_html} manquant!")
        return False
    
    content = index_html.read_text()
    
    # Vérifier Service Worker timeout handling
    if "serviceWorker.register" in content and "setTimeout" in content:
        print(f"✅ {index_html} a timeout handling pour Service Worker")
    else:
        print(f"⚠️  {index_html} manque timeout handling")
    
    # Vérifier Firebase config
    if "firebaseConfig" in content:
        print(f"✅ {index_html} a Firebase config")
    else:
        print(f"❌ {index_html} manque Firebase config!")
        return False
    
    return True

def main():
    print("""
╔══════════════════════════════════════════════════════════════╗
║       VÉRIFICATION CONFIGURATION - Miabé Assistant           ║
╚══════════════════════════════════════════════════════════════╝
    """)
    
    checks = [
        ("Fichiers d'environnement", check_env_files),
        ("Sécurité .gitignore", check_gitignore),
        ("Configuration Dart", check_dart_files),
        ("Migrations SQL", check_migrations),
        ("Dépendances Flutter", check_flutter_pubspec),
        ("Configuration Web", check_web_config),
    ]
    
    results = {}
    for name, check in checks:
        try:
            result = check()
            results[name] = result
        except Exception as e:
            print(f"❌ Erreur lors de la vérification: {e}")
            results[name] = False
    
    # Résumé
    print("\n" + "="*60)
    print("📋 RÉSUMÉ\n")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for name, result in results.items():
        status = "✅" if result else "❌"
        print(f"{status} {name}")
    
    print(f"\n{passed}/{total} vérifications passées")
    
    if passed == total:
        print("\n✅ Configuration correcte! Prêt pour le développement.\n")
        return 0
    else:
        print(f"\n⚠️  {total - passed} vérification(s) nécessite(nt) attention.\n")
        print("Voir RESOLUTION.md pour les instructions.\n")
        return 1

if __name__ == "__main__":
    sys.exit(main())
