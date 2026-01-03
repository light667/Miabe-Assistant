#!/usr/bin/env python3
"""
Upload Génie Logiciel files to Supabase Storage
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
    """Nettoie le chemin pour Supabase"""
    nfkd = unicodedata.normalize('NFKD', path)
    without_accents = ''.join([c for c in nfkd if not unicodedata.combining(c)])
    sanitized = re.sub(r'[^\w\s/.-]', '', without_accents)
    sanitized = re.sub(r'\s+', '_', sanitized)
    return sanitized

def upload_genie_logiciel():
    """Upload tous les fichiers de la filière Génie Logiciel"""
    
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    base_path = Path("resources/lpro_genie_logiciel")
    
    if not base_path.exists():
        print(f"❌ Le dossier {base_path} n'existe pas")
        return
    
    uploaded = 0
    skipped = 0
    errors = 0
    
    print(f"📤 Upload de la filière Génie Logiciel vers Supabase...")
    print(f"📂 Dossier source: {base_path}\n")
    
    # Parcourir tous les semestres
    for semestre_dir in sorted(base_path.iterdir()):
        if not semestre_dir.is_dir():
            continue
        
        # Déterminer le nom du semestre
        dir_name = semestre_dir.name.lower()
        if 'cours1' in dir_name or 's1' in dir_name:
            semestre_name = "semestre_1"
        elif 's2' in dir_name or 'cours2' in dir_name:
            semestre_name = "semestre_2"
        elif 's3' in dir_name or 'cours3' in dir_name:
            semestre_name = "semestre_3"
        else:
            print(f"⚠️  Dossier ignoré: {semestre_dir.name}")
            continue
        
        print(f"\n📚 Semestre: {semestre_name} ({semestre_dir.name})")
        
        # Parcourir les matières
        for matiere_dir in sorted(semestre_dir.iterdir()):
            if not matiere_dir.is_dir():
                continue
            
            matiere_name = matiere_dir.name
            matiere_name_clean = sanitize_path(matiere_name)
            print(f"\n  📖 Matière: {matiere_name}")
            if matiere_name != matiere_name_clean:
                print(f"     → Nettoyé: {matiere_name_clean}")
            
            # Parcourir les fichiers
            for file_path in sorted(matiere_dir.iterdir()):
                if not file_path.is_file():
                    continue
                
                if not (file_path.suffix.lower() in ['.pdf', '.docx']):
                    continue
                
                filename_clean = sanitize_path(file_path.name)
                storage_path = f"lpro_genie_logiciel/{semestre_name}/{matiere_name_clean}/{filename_clean}"
                
                try:
                    # Vérifier si existe déjà
                    try:
                        existing = supabase.storage.from_('resources').download(storage_path)
                        if existing:
                            print(f"     ⏭️  {file_path.name} (déjà présent)")
                            skipped += 1
                            continue
                    except:
                        pass
                    
                    # Lire et uploader
                    with open(file_path, 'rb') as f:
                        file_content = f.read()
                    
                    content_type = 'application/pdf' if file_path.suffix.lower() == '.pdf' else 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                    
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
                        print(f"     ✅ {file_path.name} → {filename_clean}")
                    else:
                        print(f"     ✅ {file_path.name}")
                    uploaded += 1
                    
                except Exception as e:
                    if "already exists" in str(e).lower():
                        print(f"     ⏭️  {file_path.name} (déjà présent)")
                        skipped += 1
                    else:
                        print(f"     ❌ {file_path.name}: {e}")
                        errors += 1
    
    print(f"\n{'='*60}")
    print(f"📊 Résumé de l'upload:")
    print(f"   ✅ Uploadés: {uploaded}")
    print(f"   ⏭️  Ignorés: {skipped}")
    print(f"   ❌ Erreurs: {errors}")
    print(f"   📦 Total: {uploaded + skipped + errors}")
    print(f"{'='*60}")

def update_metadata():
    """Met à jour la table resources_metadata"""
    
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    base_path = Path("resources/lpro_genie_logiciel")
    records = []
    
    print(f"\n📝 Mise à jour de la table resources_metadata...")
    
    for semestre_dir in sorted(base_path.iterdir()):
        if not semestre_dir.is_dir():
            continue
        
        dir_name = semestre_dir.name.lower()
        if 'cours1' in dir_name or 's1' in dir_name:
            semestre_name = "semestre_1"
        elif 's2' in dir_name or 'cours2' in dir_name:
            semestre_name = "semestre_2"
        elif 's3' in dir_name or 'cours3' in dir_name:
            semestre_name = "semestre_3"
        else:
            continue
        
        for matiere_dir in sorted(semestre_dir.iterdir()):
            if not matiere_dir.is_dir():
                continue
            
            matiere_name = matiere_dir.name
            matiere_name_clean = sanitize_path(matiere_name)
            
            for file_path in sorted(matiere_dir.iterdir()):
                if not file_path.is_file():
                    continue
                
                if not (file_path.suffix.lower() in ['.pdf', '.docx']):
                    continue
                
                filename_clean = sanitize_path(file_path.name)
                storage_path = f"lpro_genie_logiciel/{semestre_name}/{matiere_name_clean}/{filename_clean}"
                file_size = file_path.stat().st_size
                
                record = {
                    "filiere": "lpro_genie_logiciel",
                    "semestre": semestre_name,
                    "matiere": matiere_name,
                    "filename": file_path.name,
                    "file_path": storage_path,
                    "file_size": file_size
                }
                records.append(record)
    
    print(f"   📊 {len(records)} enregistrements à insérer")
    
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
    print("🚀 Upload Génie Logiciel vers Supabase\n")
    
    upload_genie_logiciel()
    
    response = input("\nVoulez-vous mettre à jour la table resources_metadata? (y/n): ")
    if response.lower() == 'y':
        update_metadata()
    
    print("\n✅ Script terminé!")
