#!/usr/bin/env python3
"""
Script pour tester l'accessibilité des URLs Cloudflare R2
Vérifie qu'un échantillon de PDFs est bien accessible publiquement
"""

import json
import requests
from urllib.parse import unquote
import random
import time

def test_r2_urls(sample_size=50, test_all=False):
    """
    Teste l'accessibilité des URLs R2
    
    Args:
        sample_size: Nombre de PDFs à tester (par défaut 50)
        test_all: Si True, teste tous les PDFs (peut être long!)
    """
    
    manifest_file = 'assets/resources_manifest_r2.json'
    
    try:
        with open(manifest_file, 'r', encoding='utf-8') as f:
            manifest = json.load(f)
    except FileNotFoundError:
        print(f"❌ Fichier {manifest_file} introuvable!")
        print("   Lancez d'abord: python generate_manifest_r2.py")
        return
    
    # Collecter toutes les URLs
    all_urls = []
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                for pdf in matiere['pdfs']:
                    all_urls.append({
                        'url': pdf['url'],
                        'name': pdf['name'],
                        'filiere': filiere['name'],
                        'semestre': semestre['name'],
                        'matiere': matiere['name']
                    })
    
    total_pdfs = len(all_urls)
    print(f"📊 Total de PDFs dans le manifeste: {total_pdfs}")
    
    # Sélectionner l'échantillon
    if test_all:
        urls_to_test = all_urls
        print(f"🔍 Test de TOUS les PDFs...")
    else:
        urls_to_test = random.sample(all_urls, min(sample_size, total_pdfs))
        print(f"🔍 Test d'un échantillon de {len(urls_to_test)} PDFs...")
    
    print(f"\n{'='*80}\n")
    
    # Tester les URLs
    success = 0
    errors = []
    
    for i, pdf_info in enumerate(urls_to_test, 1):
        url = pdf_info['url']
        name = pdf_info['name']
        
        try:
            # Faire une requête HEAD pour vérifier sans télécharger
            response = requests.head(url, timeout=10, allow_redirects=True)
            
            if response.status_code == 200:
                # Vérifier le Content-Type
                content_type = response.headers.get('Content-Type', '')
                
                if 'application/pdf' in content_type or 'application/octet-stream' in content_type:
                    success += 1
                    print(f"✅ [{i}/{len(urls_to_test)}] {name}")
                else:
                    errors.append({
                        'url': url,
                        'name': name,
                        'error': f'Mauvais Content-Type: {content_type}',
                        **pdf_info
                    })
                    print(f"⚠️  [{i}/{len(urls_to_test)}] {name} - Content-Type incorrect")
            else:
                errors.append({
                    'url': url,
                    'name': name,
                    'error': f'HTTP {response.status_code}',
                    **pdf_info
                })
                print(f"❌ [{i}/{len(urls_to_test)}] {name} - HTTP {response.status_code}")
        
        except requests.exceptions.RequestException as e:
            errors.append({
                'url': url,
                'name': name,
                'error': str(e),
                **pdf_info
            })
            print(f"❌ [{i}/{len(urls_to_test)}] {name} - Erreur: {e}")
        
        # Petite pause pour ne pas surcharger le serveur
        if i % 10 == 0:
            time.sleep(1)
    
    # Résumé
    print(f"\n{'='*80}")
    print(f"📊 RÉSUMÉ DES TESTS")
    print(f"{'='*80}")
    print(f"✅ Succès: {success}/{len(urls_to_test)} ({success/len(urls_to_test)*100:.1f}%)")
    print(f"❌ Erreurs: {len(errors)}/{len(urls_to_test)}")
    print(f"{'='*80}")
    
    # Détails des erreurs
    if errors:
        print(f"\n❌ DÉTAILS DES ERREURS:\n")
        for error in errors:
            print(f"📄 {error['name']}")
            print(f"   Filière: {error['filiere']}")
            print(f"   Semestre: {error['semestre']}")
            print(f"   Matière: {error['matiere']}")
            print(f"   URL: {error['url']}")
            print(f"   Erreur: {error['error']}")
            print()
        
        # Sauvegarder les erreurs
        with open('r2_test_errors.json', 'w', encoding='utf-8') as f:
            json.dump(errors, f, ensure_ascii=False, indent=2)
        print(f"💾 Erreurs sauvegardées dans: r2_test_errors.json")
    else:
        print(f"\n🎉 Tous les PDFs sont accessibles!")
    
    return success, len(errors)

def test_single_url(url):
    """Teste une seule URL"""
    print(f"🔍 Test de l'URL: {url}\n")
    
    try:
        response = requests.head(url, timeout=10, allow_redirects=True)
        
        print(f"Status: {response.status_code}")
        print(f"Content-Type: {response.headers.get('Content-Type', 'N/A')}")
        print(f"Content-Length: {response.headers.get('Content-Length', 'N/A')} bytes")
        print(f"Cache-Control: {response.headers.get('Cache-Control', 'N/A')}")
        
        if response.status_code == 200:
            print(f"\n✅ URL accessible!")
            
            # Tester le téléchargement complet
            response_full = requests.get(url, timeout=30)
            size_mb = len(response_full.content) / (1024 * 1024)
            print(f"📦 Taille du fichier: {size_mb:.2f} MB")
        else:
            print(f"\n❌ URL non accessible - HTTP {response.status_code}")
    
    except Exception as e:
        print(f"\n❌ Erreur: {e}")

def check_r2_public_url():
    """Vérifie que l'URL publique R2 est configurée"""
    
    manifest_file = 'assets/resources_manifest_r2.json'
    
    try:
        with open(manifest_file, 'r', encoding='utf-8') as f:
            manifest = json.load(f)
        
        # Récupérer une URL pour extraire le domaine
        first_url = manifest['filieres'][0]['semestres'][0]['matieres'][0]['pdfs'][0]['url']
        
        if 'pub-' in first_url and '.r2.dev' in first_url:
            print(f"✅ URL publique R2 détectée")
            base_url = first_url.split('/resources')[0]
            print(f"   Base URL: {base_url}")
            return True
        elif 'XXXXXXXXXX' in first_url:
            print(f"❌ URL publique R2 non configurée!")
            print(f"   Veuillez configurer R2_PUBLIC_URL dans generate_manifest_r2.py")
            return False
        else:
            print(f"⚠️  URL détectée mais format inconnu: {first_url}")
            return False
    
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")
        return False

if __name__ == "__main__":
    import sys
    
    print("🧪 TESTEUR D'URLs CLOUDFLARE R2\n")
    
    # Vérifier que le manifeste R2 existe
    if not check_r2_public_url():
        print("\n📝 Étapes à suivre:")
        print("   1. Configurer R2_PUBLIC_URL dans generate_manifest_r2.py")
        print("   2. Lancer: python generate_manifest_r2.py")
        print("   3. Relancer ce script")
        sys.exit(1)
    
    print()
    
    # Mode interactif
    if len(sys.argv) > 1:
        # Test d'une URL spécifique
        url = sys.argv[1]
        test_single_url(url)
    else:
        # Test d'échantillon
        print("Options:")
        print("  1. Tester un échantillon (50 PDFs)")
        print("  2. Tester TOUS les PDFs (peut être long!)")
        print("  3. Tester une URL spécifique")
        
        choice = input("\nVotre choix (1-3): ")
        
        if choice == "1":
            test_r2_urls(sample_size=50, test_all=False)
        elif choice == "2":
            confirm = input("⚠️  Cela va tester ~2322 URLs. Continuer? (y/n): ")
            if confirm.lower() == 'y':
                test_r2_urls(test_all=True)
        elif choice == "3":
            url = input("Entrez l'URL à tester: ")
            test_single_url(url)
        else:
            print("❌ Choix invalide")
