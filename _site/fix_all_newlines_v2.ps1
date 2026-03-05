
$pontosDir = ".\_pontos"

# 1. Manual Fix for known damaged files (001 and 010)
# Ponto 001
$p001 = Join-Path $pontosDir "ponto-001.md"
if (Test-Path $p001) {
    $c = Get-Content -Path $p001 -Raw -Encoding UTF8
    if ($c -match '(?m)^\s+HINO DA UMBANDA') {
        $c = $c -replace '(?m)^\s+HINO DA UMBANDA', "category: `"Hinos`"`r`ntitle: `"HINO DA UMBANDA`""
        Set-Content -Path $p001 -Value $c -Encoding UTF8
        Write-Host "Restored Ponto 001 keys"
    }
}

# Ponto 010 (Assuming similar damage)
$p010 = Join-Path $pontosDir "ponto-010.md"
if (Test-Path $p010) {
    # Need to check content to know title
    $c = Get-Content -Path $p010 -Raw -Encoding UTF8
    # If it has the empty line pattern
    if ($c -notmatch 'category:') {
        # Force restore based on known data if possible or generic fix
        # Ponto 010 title is "Hino da Umbanda (hino)"? or checking CSV
        # ID 010 is Oxalá. Title: "A estrela do oriente" (checked from CSV log earlier if available, or I'll look at the file content)
        # I will just inspect it later if this heuristic fails.
        # Attempting generic restore if line is found
        if ($c -match '(?m)^\s+(.+)$' -and $matches[1] -ne '---' -and $matches[1] -notmatch 'audios:') {
            $title = $matches[1].Trim()
            $c = $c -replace "(?m)^\s+$([Regex]::Escape($title))", "category: `"Oxalá`"`r`ntitle: `"$title`""
            Set-Content -Path $p010 -Value $c -Encoding UTF8
            Write-Host "Attempted restore Ponto 010 keys"
        }
    }
}


# 2. Bulk Fix for merged lines (category: "Val"key:)
$files = Get-ChildItem -Path $pontosDir -Recurse -Include *.md, *.html

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Regex: Find category followed immediately by another key (title, audios, ordenacao, etc)
    # Using specific lookahead prevents false positives
    if ($content -match '(category:\s*".*?")([a-z_]+:)') {
        # Replace using PowerShell string concatenation for safety against variable expansion
        $content = $content -replace '(category:\s*".*?")([a-z_]+:)', ('$1' + "`r`n" + '$2')
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Fixed newline in $($file.Name)"
    }
}
