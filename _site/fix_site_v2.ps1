$ErrorActionPreference = "Stop"
$directories = @("pages", "_posts")
$baseDir = Get-Location

function Fix-Mojibake {
    param ([string]$text)
    # Common UTF-8 bytes interpreted as Windows-1252/Latin1
    # Ã© -> é (C3 A9)
    # Ã£ -> ã (C3 A3)
    # Ã¡ -> á (C3 A1)
    # Ã¢ -> â (C3 A2)
    # Ãª -> ê (C3 AA)
    # Ã³ -> ó (C3 B3)
    # Ã´ -> ô (C3 B4)
    # Ãµ -> õ (C3 B5)
    # Ãº -> ú (C3 BA)
    # Ã§ -> ç (C3 A7)
    # Ã  -> à (C3 A0) - Note: A0 is NBSP in 1252
    # Ãc -> í (C3 AD) - Note: AD is SHY in 1252
    
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
    $out = $out -replace "Ãí", "í" # Sometimes shows as Ãí depending on font/console
    $out = $out -replace "ÃÍ", "í" 
    
    # Capital versions
    $out = $out -replace "Ã‰", "É"
    $out = $out -replace "Ãƒ", "Ã"
    $out = $out -replace "Ã‚", "Â"
    $out = $out -replace "Ã1", "Á" # C3 81? 81 is undefined in 1252? Usually pasted as unprintable
    $out = $out -replace "Ã‡", "Ç"
    
    return $out
}

foreach ($dirName in $directories) {
    $dirPath = Join-Path $baseDir $dirName
    if (Test-Path $dirPath) {
        $files = Get-ChildItem -Path $dirPath -Filter "*.md" -Recurse
        
        foreach ($file in $files) {
            Write-Host "Processing $($file.FullName)..."
            
            $content = Get-Content -Path $file.FullName -Raw
            
            # 1. Fix Mojibake
            $content = Fix-Mojibake $content
            
            # 2. Fix Image Links: (images/ -> (/assets/images/
            if ($content -match "\(images\/") {
                $content = $content -replace "\(images\/", "(/assets/images/"
            }
            
            # 3. Fix Cover Images: coverImage: "name.jpg" -> coverImage: "/assets/images/name.jpg"
            # Regex to capture content inside quotes that DOES NOT start with 
            $content = $content -replace 'coverImage:\s*"([^"/][^"]+)"', 'coverImage: "/assets/images/$1"'

            
            # Save as UTF-8 (No BOM)
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        }
    }
}

Write-Host "File processing complete."
