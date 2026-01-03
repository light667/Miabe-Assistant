#!/usr/bin/env python3
"""
Upload semestre_3 files to Supabase Storage
"""

import os
from supabase import create_client
from pathlib import Path
import unicodedata
import re

# Configuration Supabase
SUPABASE_URL = "https://gtnyqqstqfwvncnymptm.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bnlxcXN0cWZ3dm5jbnltcHRtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTk4MjM1MCwiZXhwIjoyMDgxNTU4MzUwfQ.5iN2qsjSDvnHMOIx_iZMxiEnvW2SfzbGLDElv6Zun1A"

def sanitize_path(path):
    """
    Nettoie le chemin pour Supabase en enlevant les accents et caractères spéciaux
    """
    # Normaliser Unicode (décomposer les accents)
    nfkd = unicodedata.normalize('NFKD', path)
    # Enlever les accents
    without_accents = ''.join([c for c in nfkd if not unicodedata.combining(c)])
    # Remplacer les caractères spéciaux
    sanitized = re.sub(r'[^\w\s/.-]', '', without_accents)
    # Remplacer les espaces multiples par un seul underscore
    sanitized = re.sub(r'\s+', '_', sanitized)
    return sanitized

def upload_files_to_supabase():
    """Upload tous les fichiers du semestre 3 vers Supabase"""
    
    # Créer le client Supabase
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    base_path = Path("resources/tronc_commun/semestre_3")
    
    if not base_path.exists():
        print(f"❌ Le dossier {base_path} n'existe pas")
        return
    
    uploaded = 0
    skipped = 0
    errors = 0
    
    print(f"📤 Upload des fichiers du semestre 3 vers Supabase...")
    print(f"📂 Dossier source: {base_path}\n")
    
    # Parcourir toutes les matières
    for matiere_dir in base_path.iterdir():
        if not matiere_dir.is_dir():
            continue
            
        matiere_name = matiere_dir.name
        matiere_name_clean = sanitize_path(matiere_name)
        print(f"\n📚 Matière: {matiere_name}")
        if matiere_name != matiere_name_clean:
            print(f"   → Nettoyé: {matiere_name_clean}")
        
        # Parcourir tous les fichiers
        for file_path in matiere_dir.iterdir():
            if not file_path.is_file():
                continue
                
            if not (file_path.suffix == '.pdf' or file_path.suffix == '.docx'):
                continue
            
            # Nettoyer le nom du fichier
            filename_clean = sanitize_path(file_path.name)
            
            # Chemin dans Supabase (nettoyé)
            storage_path = f"tronc_commun/semestre_3/{matiere_name_clean}/{filename_clean}"
            
            try:
                # Lire le fichier
                with open(file_path, 'rb') as f:
                    file_content = f.read()
                
                # Vérifier si le fichier existe déjà
                try:
                    existing = supabase.storage.from_('resources').download(storage_path)
                    if existing:
                        print(f"   ⏭️  {file_path.name} (déjà présent)")
                        skipped += 1
                        continue
                except:
                    # Le fichier n'existe pas, on peut uploader
                    pass
                
                # Déterminer le content-type
                content_type = 'application/pdf' if file_path.suffix == '.pdf' else 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                
                # Upload vers Supabase
                result = supabase.storage.from_('resources').upload(
                    storage_path,
                    file_content,
                    {
                        'content-type': content_type,
                        'cache-control': '3600',
                        'upsert': 'false'
                    }
                )
                
                if file_path.name != filename_clean:
                    print(f"   ✅ {file_path.name} → {filename_clean}")
                else:
                    print(f"   ✅ {file_path.name}")
                uploaded += 1
                
            except Exception as e:
                if "already exists" in str(e).lower():
                    print(f"   ⏭️  {file_path.name} (déjà présent)")
                    skipped += 1
                else:
                    print(f"   ❌ {file_path.name}: {e}")
                    errors += 1
    
    print(f"\n{'='*60}")
    print(f"📊 Résumé de l'upload:")
    print(f"   ✅ Uploadés: {uploaded}")
    print(f"   ⏭️  Ignorés: {skipped}")
    print(f"   ❌ Erreurs: {errors}")
    print(f"   📦 Total: {uploaded + skipped + errors}")
    print(f"{'='*60}")

def update_metadata_table():
    """Met à jour la table resources_metadata avec les nouveaux fichiers"""
    
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    base_path = Path("resources/tronc_commun/semestre_3")
    
    records = []
    
    print(f"\n📝 Mise à jour de la table resources_metadata...")
    
    # Liste des filières qui utilisent le tronc commun
    filieres = [
        'lf_genie_civil',
        'lf_genie_electrique',
        'lf_genie_mecanique',
        'lf_iabigdata',
        'lf_informatiquesysteme',
        'lf_logistiquetransport'
    ]
    
    for matiere_dir in base_path.iterdir():
        if not matiere_dir.is_dir():
            continue
            
        matiere_name = matiere_dir.name
        matiere_name_clean = sanitize_path(matiere_name)
        
        for file_path in matiere_dir.iterdir():
            if not file_path.is_file():
                continue
                
            if not (file_path.suffix == '.pdf' or file_path.suffix == '.docx'):
                continue
            
            filename_clean = sanitize_path(file_path.name)
            storage_path = f"tronc_commun/semestre_3/{matiere_name_clean}/{filename_clean}"
            file_size = file_path.stat().st_size
            
            # Créer un enregistrement pour chaque filière
            for filiere in filieres:
                record = {
                    "filiere": filiere,
                    "semestre": "semestre_3",
                    "matiere": matiere_name,
                    "filename": file_path.name,
                    "file_path": storage_path,
                    "file_size": file_size
                }
                records.append(record)
    
    print(f"   📊 {len(records)} enregistrements à insérer")
    
    # Insérer par lots de 100
    batch_size = 100
    inserted = 0
    
    for i in range(0, len(records), batch_size):
        batch = records[i:i + batch_size]
        try:
            result = supabase.table('resources_metadata').insert(batch).execute()
            inserted += len(batch)
            print(f"   ✅ Lot {i//batch_size + 1}: {len(batch)} enregistrements insérés")
        except Exception as e:
            if "duplicate key" in str(e).lower():
                print(f"   ⏭️  Lot {i//batch_size + 1}: Déjà présent")
            else:
                print(f"   ❌ Lot {i//batch_size + 1}: {e}")
    
    print(f"\n✅ Insertion terminée: {inserted} enregistrements")

if __name__ == "__main__":
    print("🚀 Upload Semestre 3 vers Supabase\n")
    
    # 1. Upload des fichiers
    upload_files_to_supabase()
    
    # 2. Mise à jour de la table metadata
    response = input("\nVoulez-vous mettre à jour la table resources_metadata? (y/n): ")
    if response.lower() == 'y':
        update_metadata_table()
    
    print("\n✅ Script terminé!")
