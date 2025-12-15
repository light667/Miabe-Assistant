#!/usr/bin/env python3
"""
Script de vérification des URLs R2
Vérifie que tous les PDFs sont accessibles
"""

import json
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

def check_url(pdf_info):
    """Vérifie qu'une URL est accessible"""
    try:
        response = requests.head(pdf_info['url'], timeout=10, allow_redirects=True)
        return {
            'name': pdf_info['name'],
            'url': pdf_info['url'],
            'status': response.status_code,
            'success': response.status_code == 200
        }
    except Exception as e:
        return {
            'name': pdf_info['name'],
            'url': pdf_info['url'],
            'status': 'error',
            'success': False,
            'error': str(e)
        }

def verify_r2_manifest():
    """Vérifie toutes les URLs du manifeste R2"""
    
    print("🔍 Vérification du manifeste R2...\n")
    
    # Charger le manifeste
    manifest_file = 'assets/resources_manifest_r2.json'
    try:
        with open(manifest_file, 'r', encoding='utf-8') as f:
            manifest = json.load(f)
    except FileNotFoundError:
        print(f"❌ Fichier '{manifest_file}' introuvable")
        print("   Lancez d'abord 'python upload_to_r2.py' pour générer le manifeste")
        return
    
    # Collecter toutes les URLs
    all_pdfs = []
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                for pdf in matiere['pdfs']:
                    all_pdfs.append({
                        'name': pdf['name'],
                        'url': pdf['url'],
                        'filiere': filiere['name'],
                        'semestre': semestre['name'],
                        'matiere': matiere['name']
                    })
    
    total = len(all_pdfs)
    print(f"📦 {total} PDFs à vérifier\n")
    
    # Vérifier en parallèle avec barre de progression
    results = []
    successful = 0
    failed = 0
    
    with ThreadPoolExecutor(max_workers=20) as executor:
        futures = {executor.submit(check_url, pdf): pdf for pdf in all_pdfs}
        
        with tqdm(total=total, desc="Vérification", unit="PDF") as pbar:
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
                
                if result['success']:
                    successful += 1
                else:
                    failed += 1
                
                pbar.update(1)
    
    # Afficher les résultats
    print("\n" + "=" * 70)
    print("📊 RÉSULTATS:")
    print(f"   ✅ Accessibles: {successful}/{total} ({successful*100//total}%)")
    print(f"   ❌ Inaccessibles: {failed}/{total}")
    
    # Afficher les erreurs
    if failed > 0:
        print("\n❌ PDFs INACCESSIBLES:")
        for result in results:
            if not result['success']:
                print(f"   • {result['name']}")
                print(f"     URL: {result['url']}")
                print(f"     Statut: {result['status']}")
                if 'error' in result:
                    print(f"     Erreur: {result['error']}")
                print()
    
    # Sauvegarder le rapport
    report_file = 'r2_verification_report.json'
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump({
            'total': total,
            'successful': successful,
            'failed': failed,
            'details': results
        }, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 Rapport détaillé sauvegardé: {report_file}")
    
    if failed == 0:
        print("\n✅ TOUS LES PDFs SONT ACCESSIBLES!")
        print("   Vous pouvez maintenant utiliser l'application avec R2")
    else:
        print("\n⚠️  Certains PDFs ne sont pas accessibles")
        print("   Vérifiez les URLs dans le rapport")

def sample_test():
    """Test rapide sur quelques URLs"""
    
    print("🧪 Test rapide sur 10 URLs aléatoires...\n")
    
    manifest_file = 'assets/resources_manifest_r2.json'
    try:
        with open(manifest_file, 'r', encoding='utf-8') as f:
            manifest = json.load(f)
    except FileNotFoundError:
        print(f"❌ Fichier '{manifest_file}' introuvable")
        return
    
    # Prendre les 10 premiers PDFs
    sample_pdfs = []
    for filiere in manifest['filieres'][:2]:  # 2 premières filières
        for semestre in filiere['semestres'][:1]:  # 1er semestre
            for matiere in semestre['matieres'][:1]:  # 1ère matière
                for pdf in matiere['pdfs'][:5]:  # 5 premiers PDFs
                    sample_pdfs.append(pdf)
    
    if not sample_pdfs:
        print("❌ Aucun PDF trouvé dans le manifeste")
        return
    
    print(f"Vérification de {len(sample_pdfs)} PDFs...\n")
    
    for pdf in sample_pdfs:
        result = check_url(pdf)
        status_icon = "✅" if result['success'] else "❌"
        print(f"{status_icon} {pdf['name']}")
        print(f"   {pdf['url']}")
        print(f"   Status: {result['status']}\n")

def main():
    print("""
╔══════════════════════════════════════════════════════════════════╗
║            VÉRIFICATION DES URLs CLOUDFLARE R2                   ║
╚══════════════════════════════════════════════════════════════════╝
    """)
    
    print("Options:")
    print("  1. Test rapide (10 URLs)")
    print("  2. Vérification complète (tous les PDFs)")
    print()
    
    choice = input("Votre choix (1 ou 2): ")
    
    if choice == "1":
        sample_test()
    elif choice == "2":
        # Vérifier que les dépendances sont installées
        try:
            import tqdm
        except ImportError:
            print("\n⚠️  Installation de tqdm requise:")
            print("   pip install tqdm requests\n")
            return
        
        verify_r2_manifest()
    else:
        print("❌ Choix invalide")

if __name__ == "__main__":
    main()
