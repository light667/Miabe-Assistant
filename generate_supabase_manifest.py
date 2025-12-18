#!/usr/bin/env python3
"""
Generate resources manifest from Supabase Storage
All filières point to tronc_commun for S1 and S2
"""

import json
from supabase import create_client
import os

# Configuration Supabase
SUPABASE_URL = "https://gtnyqqstqfwvncnymptm.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bnlxcXN0cWZ3dm5jbnltcHRtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTk4MjM1MCwiZXhwIjoyMDgxNTU4MzUwfQ.y7IZiOwner7JLT5-Gp3ngnqy-YrOlbkSI7hgPMLWlOM"

# Liste des filières
FILIERES = [
    "lf_genie_civil",
    "lf_genie_electrique", 
    "lf_genie_mecanique",
    "lf_iabigdata",
    "lf_informatiquesysteme",
    "lf_logistiquetransport"
]

def fetch_all_files():
    """Récupère tous les fichiers en naviguant dans l'arborescence locale"""
    import os
    
    all_files = []
    base_path = "resources/tronc_commun"
    
    # Parcourir semestre_1 et semestre_2
    for semestre in ["semestre_1", "semestre_2"]:
        semestre_path = os.path.join(base_path, semestre)
        if not os.path.exists(semestre_path):
            continue
            
        # Parcourir les matières
        for matiere in os.listdir(semestre_path):
            matiere_path = os.path.join(semestre_path, matiere)
            if not os.path.isdir(matiere_path):
                continue
                
            # Lister les PDFs
            for pdf in os.listdir(matiere_path):
                if pdf.endswith('.pdf') or pdf.endswith('.docx'):
                    file_path = f"tronc_commun/{semestre}/{matiere}/{pdf}"
                    all_files.append({"name": file_path})
    
    return all_files

def get_public_url(file_path):
    """Génère l'URL publique pour un fichier"""
    return f"{SUPABASE_URL}/storage/v1/object/public/resources/{file_path}"

def organize_by_structure(files):
    """Organise les fichiers par semestre/matière"""
    structure = {}
    
    for file in files:
        name = file.get("name", "")
        
        # Ignorer les dossiers
        if not name or name.endswith("/"):
            continue
            
        # Parser le chemin: tronc_commun/semestre_X/matiere/fichier.pdf
        parts = name.split("/")
        if len(parts) < 4:
            continue
            
        tronc, semestre, matiere, fichier = parts[0], parts[1], parts[2], parts[3]
        
        if semestre not in structure:
            structure[semestre] = {}
            
        if matiere not in structure[semestre]:
            structure[semestre][matiere] = []
            
        structure[semestre][matiere].append({
            "name": fichier,
            "url": get_public_url(name),
            "source": "supabase"
        })
    
    return structure

def generate_manifest(structure):
    """Génère le manifest JSON pour toutes les filières"""
    manifest = {"filieres": []}
    
    for filiere in FILIERES:
        filiere_data = {
            "name": filiere,
            "semestres": []
        }
        
        # Pour chaque semestre dans la structure
        for semestre_name in sorted(structure.keys()):
            semestre_data = {
                "name": semestre_name,
                "matieres": []
            }
            
            # Pour chaque matière
            for matiere_name in sorted(structure[semestre_name].keys()):
                matiere_data = {
                    "name": matiere_name,
                    "folder": f"tronc_commun/{semestre_name}/{matiere_name}",
                    "pdfs": structure[semestre_name][matiere_name]
                }
                semestre_data["matieres"].append(matiere_data)
            
            filiere_data["semestres"].append(semestre_data)
        
        manifest["filieres"].append(filiere_data)
    
    return manifest

def main():
    print("🔍 Récupération des fichiers depuis Supabase...")
    files = fetch_all_files()
    print(f"✅ {len(files)} fichiers récupérés")
    
    print("\n📂 Organisation de la structure...")
    structure = organize_by_structure(files)
    
    total_pdfs = sum(
        len(pdfs) 
        for semestre in structure.values() 
        for pdfs in semestre.values()
    )
    print(f"✅ {total_pdfs} PDFs organisés")
    
    print("\n📝 Génération du manifest...")
    manifest = generate_manifest(structure)
    
    # Sauvegarder
    output_file = "assets/resources_manifest_online.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Manifest généré: {output_file}")
    print(f"\n📊 Résumé:")
    print(f"   - {len(manifest['filieres'])} filières")
    print(f"   - {len(structure)} semestres")
    print(f"   - {total_pdfs} PDFs total")
    
    # Vérification
    for filiere in manifest["filieres"]:
        pdfs_count = sum(
            len(matiere["pdfs"]) 
            for semestre in filiere["semestres"] 
            for matiere in semestre["matieres"]
        )
        print(f"   - {filiere['name']}: {pdfs_count} PDFs")

if __name__ == "__main__":
    main()
