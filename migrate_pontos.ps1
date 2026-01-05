
$htmlContent = Get-Content "pontoscantados_antigos.html" -Raw
$outputMd = "pontos-cantados.md"
$audioDir = "assets/audio"
$docsDir = "assets/docs"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $audioDir | Out-Null
New-Item -ItemType Directory -Force -Path $docsDir | Out-Null

# Initialize Markdown content
$mdContent = @"
---
layout: page
title: Pontos Cantados
---

Com o objetivo de preservar nossa cultura e criar um arquivo de pontos para as futuras gerações, disponibilizamos abaixo nossa coletânea de pontos cantados.

### Livro de Pontos
- [Baixar Pontos_Cantados DOX](/tmm7f/assets/docs/pontos_cantados.docx)
- [Baixar Pontos_Cantados PDF](/tmm7f/assets/docs/pontos_cantados.pdf)

---

## Lista de Pontos

"@

# Regex to find songs
# Matches <div class="musica"> ... <h3>TITLE</h3> ... audio ... </div>
# This is a bit complex for regex, so we'll split by <div class="musica">
$sections = $htmlContent -split '<div class="musica">'
$songCount = 0

foreach ($section in $sections) {
    if ($section -notmatch "<h3>(.*?)</h3>") { continue }
    
    $title = $matches[1] -replace '&#8220;', '"' -replace '&#8221;', '"' -replace '&#8217;', "'"
    if ($title -match "^\s*<") { continue } # Skip empty or malformed titles

    $songCount++
    $songNum = "{0:D3}" -f $songCount

    $mdContent += "`n### $songNum - $title`n"
    
    # Extract Lyrics
    if ($section -match '<div class="letra">([\s\S]*?)</div>') {
        $lyrics = $matches[1] -replace '<p>', '' -replace '</p>', "`n" -replace '<br />', "`n" 
        $mdContent += "`n$lyrics`n"
    }

    # Extract Audio
    # Pattern: <p>(<em>(.*?)</em>)?\s*<audio.*?</audio></p>
    # or just simple audio tags if we want to be robust
    
    # Find all audio blocks
    $audioMatches = [regex]::Matches($section, '<p>(?:<em>(.*?)</em>)?\s*<audio.*?controls="controls".*?src="(.*?)".*?</audio></p>')
    
    $versionCount = 0
    foreach ($match in $audioMatches) {
        $versionCount++
        $label = if ($match.Groups[1].Value) { $match.Groups[1].Value } else { "Versão $versionCount" }
        $url = $match.Groups[2].Value
        
        if ($url) {
            # Download file
            $ext = [System.IO.Path]::GetExtension($url)
            # Sanitize title for filename
            $safeTitle = $title -replace '[^a-zA-Z0-9]', '-' -replace '-+', '-' -replace '-$', ''
            $filename = "$songNum-$safeTitle-v$versionCount$ext".ToLower()
            $localPath = Join-Path $audioDir $filename
            
            try {
                Invoke-WebRequest -Uri $url -OutFile $localPath
                $mdContent += "`n**$label**`n"
                $mdContent += "<audio controls><source src=`"/tmm7f/assets/audio/$filename`" type=`"audio/mpeg`">Seu navegador não suporta áudio.</audio>`n"
            }
            catch {
                Write-Host "Error downloading $url for $title"
            }
        }
    }
    
    $mdContent += "`n---`n"
}

# Download Docs
$docUrls = @(
    "https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.docx",
    "https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.pdf"
)

foreach ($url in $docUrls) {
    try {
        $filename = [System.IO.Path]::GetFileName($url)
        Invoke-WebRequest -Uri $url -OutFile (Join-Path $docsDir $filename)
    }
    catch {
        Write-Host "Error downloading doc: $url"
    }
}

$mdContent | Set-Content $outputMd -Encoding UTF8
Write-Host "Migration complete! Processed $songCount songs."
