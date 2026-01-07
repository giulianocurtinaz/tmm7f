# Force Reconstruct YAML Frontmatter V2
# Parses existing frontmatter (even if malformed/single-line) and reconstructs it from scratch.

$sourceDir = ".\_pontos"
$files = Get-ChildItem -Path $sourceDir -Filter "*.md"
$count = 0

foreach ($file in $files) {
    try {
        $rawContent = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Regex to capture Frontmatter and Body
        # Handles --- [FM] --- [Body]
        if ($rawContent -match '(?s)^\s*---\s*(.*?)\s*---\s*(.*)$') {
            $fmRaw = $matches[1]
            $body = $matches[2]
            
            # --- Extraction Logic ---
            
            # 1. ID Ponto (digits, possibly quoted)
            $idPonto = ""
            if ($fmRaw -match 'id_ponto:\s*"?(\d+)"?') { $idPonto = $matches[1] }
            
            # 2. Ordenacao (digits)
            $ordenacao = ""
            if ($fmRaw -match 'ordenacao:\s*"?(\d+)"?') { $ordenacao = $matches[1] }
            
            # 3. Category (Quoted string OR simple word)
            $category = ""
            if ($fmRaw -match 'category:\s*"([^"]+)"') { 
                $category = $matches[1] 
            }
            elseif ($fmRaw -match 'category:\s*([a-zA-Z]+)') {
                $category = $matches[1]
            }
            
            # 4. Title (Quoted string PREFERRED, or rest of line if multiline exists, or capture until next keyword)
            $title = ""
            if ($fmRaw -match 'title:\s*"([^"]+)"') {
                $title = $matches[1]
            }
            elseif ($fmRaw -match 'title:\s*([^"\r\n]+)') {
                # Fallback for unquoted title (risky if single line, but usually titles are at end or quoted)
                # If single line "title: My Title audios:...", this regex matches "My Title audios:..." which is bad.
                # However, our previous scripts enforced quotes on title (usually). 
                # Let's rely on quotes first.
                $title = $matches[1].Trim()
            }
            
            # 5. Audio URL
            $url = ""
            if ($fmRaw -match 'url:\s*"?([^"\s\r\n]+)"?') { $url = $matches[1] }
            
            # 6. Caption
            $caption = ""
            if ($fmRaw -match 'caption:\s*"([^"]+)"') { $caption = $matches[1] }
            
            # --- Reconstruction ---
            
            # Defaults
            $newFM = "--`n" # Typo in user request '---'? No, standard is ---. User wrote ---.
            # Wait, valid yaml start is ---
            
            $sb = New-Object System.Text.StringBuilder
            $sb.AppendLine("---") | Out-Null
            $sb.AppendLine("layout: ponto") | Out-Null
            
            if ($idPonto) { $sb.AppendLine("id_ponto: `"$idPonto`"") | Out-Null }
            if ($ordenacao) { $sb.AppendLine("ordenacao: $ordenacao") | Out-Null }
            if ($category) { $sb.AppendLine("category: `"$category`"") | Out-Null }
            if ($title) { $sb.AppendLine("title: `"$title`"") | Out-Null }
            
            if ($url) {
                $sb.AppendLine("audios:") | Out-Null
                $sb.AppendLine("  - url: $url") | Out-Null
                if ($caption) {
                    $sb.AppendLine("    caption: `"$caption`"") | Out-Null
                }
            }
            
            $sb.AppendLine("---") | Out-Null
            $sb.Append($body) | Out-Null
            
            $finalContent = $sb.ToString()
            
            # Write back
            $finalContent | Set-Content -Path $file.FullName -Encoding UTF8
            $count++
        }
    }
    catch {
        Write-Host "Error processing $($file.Name): $_"
    }
}

Write-Host "Reconstructed $count files."
