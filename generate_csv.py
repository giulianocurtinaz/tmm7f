
import os
import yaml
import csv
import re

def get_frontmatter(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        # Parse YAML front matter between first two ---
        match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
        if match:
            try:
                return yaml.safe_load(match.group(1))
            except yaml.YAMLError:
                return None
    return None

def generate_csv():
    pontos_dir = '_pontos'
    output_file = 'revisao_pontos.csv'
    
    data = []
    
    # Walk through directory
    for root, dirs, files in os.walk(pontos_dir):
        for file in files:
            if file.endswith('.md') or file.endswith('.html'):
                file_path = os.path.join(root, file)
                fm = get_frontmatter(file_path)
                
                if fm:
                    # Get fields, default to empty string if missing
                    ponto_id = fm.get('id_ponto', '')
                    category = fm.get('category', '')
                    title = fm.get('title', '')
                    
                    # Try to convert id to int for sorting, keep original if fails
                    try:
                        sort_id = int(ponto_id)
                    except (ValueError, TypeError):
                        sort_id = 999999 # Push to end if not a number
                        
                    data.append({
                        'sort_id': sort_id,
                        'id': ponto_id,
                        'category': category,
                        'title': title
                    })

    # Sort by ID
    data.sort(key=lambda x: x['sort_id'])
    
    # Write CSV
    with open(output_file, 'w', newline='', encoding='utf-8-sig') as csvfile:
        fieldnames = ['id', 'categoria', 'title']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter=';')
        
        writer.writeheader()
        for row in data:
            writer.writerow({
                'id': row['id'],
                'categoria': row['category'],
                'title': row['title']
            })
            
    print(f"CSV created: {output_file}")
    print(f"Total records: {len(data)}")

if __name__ == "__main__":
    generate_csv()
