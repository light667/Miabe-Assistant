#!/usr/bin/env python3
"""
Generate complete resources manifest including both tronc_commun and lpro_genie_logiciel
"""

import json
import os
import unicodedata
import re

# Configuration Supabase
SUPABASE_URL = "https://gtnyqqstqfwvncnymptm.supabase.co"

# Filières avec tronc commun
FILIERES_TRONC_COMMUN = [
    "lf_genie_civil",
    "lf_genie_electrique", 
    "lf_genie_mecanique",
    "lf_iabigdata",
    "lf_informatiquesysteme",
    "lf_logistiquetransport"
]

def sanitize_path(path):
    """Nettoie le chemin pour Supabase"""
    nfkd = unicodedata.normalize('NFKD', path)
    without_accents = ''.join([c for c in nfkd if not unicodedata.combining(c)])
    sanitized = re.sub(r'[^\w\s/.-]', '', without_accents)
    sanitized = re.sub(r'\s+', '_', sanitized)
    return sanitized

def get_public_url(file_path):
    """Génère l'URL publique pour un fichier"""
    return f"{SUPABASE_URL}/storage/v1/object/public/resources/{file_path}"

def fetch_tronc_commun_files():
    """Récupère les fichiers du tronc commun (S1, S2, S3)"""
    structure = {}
    base_path = "resources/tronc_commun"
    
    for semestre in ["semestre_1", "semestre_2", "semestre_3"]:
        semestre_path = os.path.join(base_path, semestre)
        if not os.path.exists(semestre_path):
            continue
        
        structure[semestre] = {}
        
        for matiere in os.listdir(semestre_path):
            matiere_path = os.path.join(semestre_path, matiere)
            if not os.path.isdir(matiere_path):
                continue
            
            matiere_clean = sanitize_path(matiere)
            structure[semestre][matiere] = []
            
            for fichier in os.listdir(matiere_path):
                if fichier.endswith('.pdf') or fichier.endswith('.docx'):
                    fichier_clean = sanitize_path(fichier)
                    file_path = f"tronc_commun/{semestre}/{matiere_clean}/{fichier_clean}"
                    
                    structure[semestre][matiere].append({
                        "name": fichier,
                        "url": get_public_url(file_path),
                        "source": "supabase"
                    })
    
    return structure

def fetch_genie_logiciel_files():
    """Récupère les fichiers de Génie Logiciel avec structure mixte"""
    structure = {}
    base_path = "resources/lpro_genie_logiciel"
    
    if not os.path.exists(base_path):
        return structure
    
    # Mapping des dossiers vers les semestres
    semestre_mapping = {
        "cours1I": "semestre_1",
        "CoursS2I": "semestre_2",
        "CoursS3I": "semestre_3"
    }
    
    for folder_name, semestre_name in semestre_mapping.items():
        folder_path = os.path.join(base_path, folder_name)
        if not os.path.exists(folder_path):
            continue
        
        structure[semestre_name] = {}
        
        # Cas spécial pour semestre_1 (cours1I): fichiers directement dans le dossier
        if folder_name == "cours1I":
            # Tous les fichiers vont dans une matière "Ressources Générales"
            matiere_name = "Ressources Générales"
            structure[semestre_name][matiere_name] = []
            
            for fichier in os.listdir(folder_path):
                fichier_path = os.path.join(folder_path, fichier)
                if os.path.isfile(fichier_path) and (fichier.endswith('.pdf') or fichier.endswith('.docx')):
                    fichier_clean = sanitize_path(fichier)
                    file_path = f"lpro_genie_logiciel/{semestre_name}/Ressources_Generales/{fichier_clean}"
                    
                    structure[semestre_name][matiere_name].append({
                        "name": fichier,
                        "url": get_public_url(file_path),
                        "source": "supabase"
                    })
        
        # Cas normal: sous-dossiers de matières (S2 et S3)
        else:
            for item in os.listdir(folder_path):
                item_path = os.path.join(folder_path, item)
                if not os.path.isdir(item_path):
                    continue
                
                matiere_name = item
                matiere_clean = sanitize_path(matiere_name)
                structure[semestre_name][matiere_name] = []
                
                # Parcourir les fichiers et sous-dossiers de la matière
                for root, dirs, files in os.walk(item_path):
                    for fichier in files:
                        if fichier.endswith('.pdf') or fichier.endswith('.docx'):
                            fichier_clean = sanitize_path(fichier)
                            # Calculer le chemin relatif depuis la matière
                            rel_path = os.path.relpath(root, item_path)
                            if rel_path == ".":
                                file_path = f"lpro_genie_logiciel/{semestre_name}/{matiere_clean}/{fichier_clean}"
                            else:
                                rel_path_clean = sanitize_path(rel_path.replace(os.sep, '/'))
                                file_path = f"lpro_genie_logiciel/{semestre_name}/{matiere_clean}/{rel_path_clean}/{fichier_clean}"
                            
                            structure[semestre_name][matiere_name].append({
                                "name": fichier,
                                "url": get_public_url(file_path),
                                "source": "supabase"
                            })
    
    return structure

def generate_manifest():
    """Génère le manifest complet"""
    manifest = {"filieres": []}
    
    # 1. Filières avec tronc commun
    print("🔍 Récupération tronc commun...")
    tronc_structure = fetch_tronc_commun_files()
    
    for filiere in FILIERES_TRONC_COMMUN:
        filiere_data = {
            "name": filiere,
            "semestres": []
        }
        
        for semestre_name in sorted(tronc_structure.keys()):
            semestre_data = {
                "name": semestre_name,
                "matieres": []
            }
            
            for matiere_name in sorted(tronc_structure[semestre_name].keys()):
                matiere_clean = sanitize_path(matiere_name)
                matiere_data = {
                    "name": matiere_name,
                    "folder": f"tronc_commun/{semestre_name}/{matiere_clean}",
                    "pdfs": tronc_structure[semestre_name][matiere_name]
                }
                semestre_data["matieres"].append(matiere_data)
            
            filiere_data["semestres"].append(semestre_data)
        
        manifest["filieres"].append(filiere_data)
    
    # 2. Génie Logiciel avec structure spécifique
    print("🔍 Récupération Génie Logiciel...")
    gl_structure = fetch_genie_logiciel_files()
    
    if gl_structure:
        filiere_data = {
            "name": "lpro_genie_logiciel",
            "semestres": []
        }
        
        for semestre_name in sorted(gl_structure.keys()):
            semestre_data = {
                "name": semestre_name,
                "matieres": []
            }
            
            for matiere_name in sorted(gl_structure[semestre_name].keys()):
                matiere_clean = sanitize_path(matiere_name)
                matiere_data = {
                    "name": matiere_name,
                    "folder": f"lpro_genie_logiciel/{semestre_name}/{matiere_clean}",
                    "pdfs": gl_structure[semestre_name][matiere_name]
                }
                semestre_data["matieres"].append(matiere_data)
            
            filiere_data["semestres"].append(semestre_data)
        
        manifest["filieres"].append(filiere_data)
    
    return manifest, tronc_structure, gl_structure

def main():
    manifest, tronc_structure, gl_structure = generate_manifest()
    
    # Calculer les statistiques
    tronc_pdfs = sum(
        len(pdfs) 
        for semestre in tronc_structure.values() 
        for pdfs in semestre.values()
    )
    
    gl_pdfs = sum(
        len(pdfs) 
        for semestre in gl_structure.values() 
        for pdfs in semestre.values()
    )
    
    print(f"✅ Tronc commun: {tronc_pdfs} PDFs")
    print(f"✅ Génie Logiciel: {gl_pdfs} PDFs")
    
    # Sauvegarder
    output_file = "app/assets/resources_manifest_online.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Manifest généré: {output_file}")
    print(f"\n📊 Résumé:")
    print(f"   - {len(manifest['filieres'])} filières")
    
    for filiere in manifest["filieres"]:
        pdfs_count = sum(
            len(matiere["pdfs"]) 
            for semestre in filiere["semestres"] 
            for matiere in semestre["matieres"]
        )
        print(f"   - {filiere['name']}: {pdfs_count} PDFs ({len(filiere['semestres'])} semestres)")

if __name__ == "__main__":
    main()
