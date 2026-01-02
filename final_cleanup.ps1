$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$assetsDir = Join-Path $baseDir "assets\images"
$dirsToProcess = @("pages", "_posts")

# 1. Helper to normalize filenames
function Get-NormalizedName {
    param ([string]$filename)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    $ext = [System.IO.Path]::GetExtension($filename)
    
    # Remove accents
    $text = $name.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $text.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $text = $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
    
    # Lowercase and hyphenate
    $cleanName = $text.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-]', ''
    return "$cleanName$($ext.ToLower())"
}

# 2. Fix Mojibake Function
function Fix-Mojibake {
    param ([string]$text)
    $out = $text -replace "Ã©", "é"
    $out = $out -replace "Ã£", "ã"
    $out = $out -replace "Ã¡", "á"
    $out = $out -replace "Ã¢", "â"
    $out = $out -replace "Ãª", "ê"
    $out = $out -replace "Ã³", "ó"
    $out = $out -replace "Ã´", "ô"
    $out = $out -replace "Ãµ", "õ"
    $out = $out -replace "Ãº", "ú"
    $out = $out -replace "Ã§", "ç"
    $out = $out -replace "Ã ", "à"  
    $out = $out -replace "Ãí", "í"
    $out = $out -replace "ÃÍ", "í"
    $out = $out -replace "Ã‰", "É"
    $out = $out -replace "Ãƒ", "Ã"
    $out = $out -replace "Ã‚", "Â"
    $out = $out -replace "Ã1", "Á"
    $out = $out -replace "Ã‡", "Ç"
    return $out
}

# 3. Rename files in assets/images
if (Test-Path $assetsDir) {
    Write-Host "Normalizing files in $assetsDir..."
    $files = Get-ChildItem -Path $assetsDir -File
    foreach ($file in $files) {
        $newName = Get-NormalizedName $file.Name
        if ($file.Name -ne $newName) {
            $newPath = Join-Path $assetsDir $newName
            # Handle duplicates
            if (Test-Path $newPath) {
                Write-Warning "Duplicate found for $newName. Keeping existing, checking if we can just rename source."
                # If target exists, we assume it's the canonical one. We basically 'merge' them.
                # But for safety, let's just delete the pending rename one if content is same? 
                # Or just skip renaming and rely on the content update to point to the normalized one.
            }
            else {
                Rename-Item -Path $file.FullName -NewName $newName
                Write-Host "Renamed: $($file.Name) -> $newName"
            }
        }
    }
}

# 4. Process MD files
foreach ($dir in $dirsToProcess) {
    $fullPath = Join-Path $baseDir $dir
    if (Test-Path $fullPath) {
        $mdFiles = Get-ChildItem -Path $fullPath -Filter "*.md" -Recurse
        
        foreach ($file in $mdFiles) {
            Write-Host "Processing $($file.Name)..."
            $content = Get-Content -Path $file.FullName -Raw
            
            # A. Fix Encoding
            $content = Fix-Mojibake $content
            
            # B. Fix Cover Images
            # Logic: Find coverImage: "ANYTHING" -> Extract filename -> Normalize -> Rewrite path
            $content = [Regex]::Replace($content, 'coverImage:\s*"([^"]+)"', {
                    param($match)
                    $originalPath = $match.Groups[1].Value
                    $filename = [System.IO.Path]::GetFileName($originalPath)
                    $normalized = Get-NormalizedName $filename
                    return 'coverImage: "/tmm7f/assets/images/' + $normalized + '"'
                })
            
            # C. Fix Markdown Image Links
            # Logic: Find ](ANYTHING) -> if it looks like an image path -> partial fix
            # We look for ]( ... ) pattern.
            $content = [Regex]::Replace($content, '!\[(.*?)\]\((.*?)\)', {
                    param($match)
                    $alt = $match.Groups[1].Value
                    $url = $match.Groups[2].Value
                
                    # Check if it's an image we manage (has extension or 'images' in path)
                    if ($url -match "images" -or $url -match "\.(jpg|jpeg|png|gif|webp)$") {
                        $filename = [System.IO.Path]::GetFileName($url)
                        $normalized = Get-NormalizedName $filename
                        return "![$alt](/tmm7f/assets/images/$normalized)"
                    }
                    return $match.Value
                })

            # D. Fix HTML Img Tags (if any)
            $content = [Regex]::Replace($content, '<img[^>]+src="([^"]+)"', {
                    param($match)
                    $fullMatch = $match.Value
                    $url = $match.Groups[1].Value
                    if ($url -match "images" -or $url -match "\.(jpg|jpeg|png|gif|webp)$") {
                        $filename = [System.IO.Path]::GetFileName($url)
                        $normalized = Get-NormalizedName $filename
                        # Replace simply the src attribute part
                        return $fullMatch -replace [Regex]::Escape($url), "/tmm7f/assets/images/$normalized"
                    }
                    return $fullMatch
                })
            
            # Save UTF-8
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        }
    }
}

Write-Host "Cleanup Complete."
