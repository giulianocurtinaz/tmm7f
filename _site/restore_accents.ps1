$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$dirsToProcess = @("pages", "_posts")

function Restore-Accents {
    param ([string]$text)
    
    # User specified replacements for double-encoded UTF-8
    # Interpreted as: the string contains the literal characters "Ã" + "©", etc.
    
    $out = $text -replace "Ã©", "é"
    $out = $out -replace "Ã£", "ã"
    $out = $out -replace "Ã¡", "á"
    $out = $out -replace "Ãª", "ê"
    $out = $out -replace "Ã§", "ç"
    $out = $out -replace "Ã³", "ó"
    $out = $out -replace "Ãº", "ú"
    $out = $out -replace "Ã´", "ô"
    
    # Special case: Ã followed by space (or NBSP) -> à
    # Regex for Ã followed by space (0x20) or NBSP (0xA0)
    $out = $out -replace "Ã[\u0020\u00A0]", "à"
    
    return $out
}

foreach ($dir in $dirsToProcess) {
    $fullPath = Join-Path $baseDir $dir
    if (Test-Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -Filter "*.md" -Recurse
        
        foreach ($file in $files) {
            Write-Host "Processing $($file.Name)..."
            
            # Read raw content. We assume the file is readable as UTF-8 or Default.
            # If it's double encoded, the characters Ã and © will be present.
            $content = Get-Content -Path $file.FullName -Raw
            
            $newContent = Restore-Accents $content
            
            if ($content -ne $newContent) {
                Write-Host "  Fixed accents."
                # Save UTF-8 No BOM
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
            }
        }
    }
}
Write-Host "Accent restoration complete."
