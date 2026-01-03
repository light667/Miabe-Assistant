#!/usr/bin/env python3
import os
from supabase import create_client
from pathlib import Path

# Configuration Supabase (from upload_semestre3_to_supabase.py)
SUPABASE_URL = "https://gtnyqqstqfwvncnymptm.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bnlxcXN0cWZ3dm5jbnltcHRtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTk4MjM1MCwiZXhwIjoyMDgxNTU4MzUwfQ.5iN2qsjSDvnHMOIx_iZMxiEnvW2SfzbGLDElv6Zun1A"

def upload_resource():
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Path relative to 'app' directory (assumed CWD)
    file_path = Path("../resources/competences/FREECAD_COURS.pdf")
    
    if not file_path.exists():
        # Try finding it relative to where script might be if not running from app root
        file_path = Path("resources/competences/FREECAD_COURS.pdf")
        if not file_path.exists():
           # Try absolute path
           file_path = Path("/home/light667/Miabe-Assistant/resources/competences/FREECAD_COURS.pdf")
    
    if not file_path.exists():
        print(f"❌ File not found: {file_path}")
        return

    print(f"🚀 Uploading {file_path}...")
    
    try:
        with open(file_path, "rb") as f:
            file_content = f.read()
            
        storage_path = "competences/FREECAD_Cours.pdf" # Desired path in bucket
        
        supabase.storage.from_("resources").upload(
            storage_path,
            file_content,
            {
                "content-type": "application/pdf",
                "upsert": "true"
            }
        )
        print("✅ Upload successful!")
        
        public_url = supabase.storage.from_("resources").get_public_url(storage_path)
        print(f"🌍 Public URL: {public_url}")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    upload_resource()
