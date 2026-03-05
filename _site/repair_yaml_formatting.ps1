# Repair YAML Frontmatter Formatting
# Enforces newlines before specific keys to fix potential single-line corruption.

$sourceDir = ".\_pontos"
$files = Get-ChildItem -Path $sourceDir -Filter "*.md"
$count = 0

foreach ($file in $files) {
    $rawContent = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check if file has frontmatter
    if ($rawContent -match '(?ms)^---\s*(.*?)\s*---(.*)$') {
        $frontmatter = $matches[1]
        $body = $matches[2]
        
        # New clean frontmatter construction
        $newFM = $frontmatter

        # Replace non-newline whitespace before keys with a newline
        # Keys: id_ponto, ordenacao, category, title, audios
        
        # Ensure 'layout:' is at start, usually it matches fine.
        
        # Determine if we need to fix. We'll just run replacements.
        # Note: We use regex looking for the key preceded by spaces/tabs but NOT a newline (or start of string)
        # Actually simplest is just to blindly replace ' key:' with "`nkey:"? 
        # But we must be careful not to match inside values (unlikely for these specific keys).

        # 1. layout (if not at start)
        $newFM = $newFM -replace '(?<!^)\s+layout:', "`nlayout:"
        
        # 2. id_ponto
        $newFM = $newFM -replace '\s+id_ponto:', "`nid_ponto:"
        
        # 3. ordenacao
        $newFM = $newFM -replace '\s+ordenacao:', "`nordenacao:"
        
        # 4. category
        $newFM = $newFM -replace '\s+category:', "`ncategory:"
        
        # 5. title
        $newFM = $newFM -replace '\s+title:', "`ntitle:"
        
        # 6. audios
        $newFM = $newFM -replace '\s+audios:', "`naudios:"
        
        # 7. List items (- url)
        # We need to make sure '- url' is on a new indented line
        $newFM = $newFM -replace '\s+-\s+url:', "`n  - url:"
        
        # 8. caption
        $newFM = $newFM -replace '\s+caption:', "`n    caption:"
        
        # Clean up multiple newlines if any
        $newFM = $newFM -replace '[\r\n]+', "`n"
        
        # Reconstruct file
        # Ensure one newline after opening --- and one before closing ---
        $newContent = "---`n" + $newFM.Trim() + "`n---" + $body

        if ($newContent -ne $rawContent) {
            $newContent | Set-Content -Path $file.FullName -Encoding UTF8
            # Write-Host "Fixed: $($file.Name)"
            $count++
        }
    }
}

Write-Host "Total files repaired: $count"
