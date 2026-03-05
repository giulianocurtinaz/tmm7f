import glob
import os
import re

def migrate_files():
    files = glob.glob('_pontos/*.md')
    print(f"Found {len(files)} files to process.")
    
    for filepath in files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Check if ordenacao already exists to avoid duplication
        if 'ordenacao:' in content:
            print(f"Skipping {filepath} (ordenacao already exists)")
            continue
            
        # extract id_ponto
        match = re.search(r'id_ponto:\s*["\']?(\d+)["\']?', content)
        if match:
            id_val_str = match.group(1)
            try:
                id_val_int = int(id_val_str)
                
                # regex to insert ordenacao after id_ponto line
                # We look for the line containing id_ponto and replace it with itself + newline + ordenacao
                pattern = r'(id_ponto:.*)(\n)'
                replacement = f'\\1\\2ordenacao: {id_val_int}\\2'
                
                new_content = re.sub(pattern, replacement, content, count=1)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                    
            except ValueError:
                print(f"Error parsing ID for {filepath}")
        else:
            print(f"No id_ponto found in {filepath}")

if __name__ == "__main__":
    migrate_files()
