
# Configurations
$WorkDir = "C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp"
$HtmlPath = Join-Path $WorkDir "pontoscantados_antigos.html"
$AudioDir = Join-Path $WorkDir "assets\audio"
$MdPath = Join-Path $WorkDir "pontos-cantados.md"

# 1. Cleanup
Write-Host "Cleaning up directories..." -ForegroundColor Yellow
if (Test-Path $AudioDir) {
    Remove-Item "$AudioDir\*" -Include *.* -Force -Recurse
}
else {
    New-Item -ItemType Directory -Path $AudioDir | Out-Null
}

Clear-Content $MdPath -ErrorAction SilentlyContinue

# 2. Parse HTML Content
Write-Host "Reading HTML..." -ForegroundColor Cyan
$HtmlContent = Get-Content $HtmlPath -Raw -Encoding UTF8

# Helper to remove HTML tags
function Remove-HtmlTags {
    param ($Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    # Decode HTML entities
    $Text = [System.Web.HttpUtility]::HtmlDecode($Text)
    # Remove HTML tags
    $Text = $Text -replace '<[^>]+>', ''
    return $Text.Trim()
}

# Helper to slugify
function Get-Slug {
    param ($Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "audio" }
    $Text = $Text.ToLower()
    $Text = $Text -replace '[áàâãä]', 'a'
    $Text = $Text -replace '[éèêë]', 'e'
    $Text = $Text -replace '[íìîï]', 'i'
    $Text = $Text -replace '[óòôõö]', 'o'
    $Text = $Text -replace '[úùûü]', 'u'
    $Text = $Text -replace '[ç]', 'c'
    $Text = $Text -replace '[^a-z0-9\s-]', ''
    $Text = $Text -replace '\s+', '-'
    $Text = $Text -replace '-+', '-'
    if ($Text.Length -gt 50) { $Text = $Text.Substring(0, 50) }
    return $Text.Trim('-')
}

# 3. Setup Markdown Header
$MarkdownContent = @"
---
layout: page
title: Pontos Cantados
permalink: /pontos-cantados/
---

<div class="downloads-section" style="margin-bottom: 30px; padding: 20px; background: #f5f5f5; border-radius: 8px;">
    <h3>Baixe o Livro de Pontos</h3>
    <p>
        <a href="https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.docx" class="btn btn-primary" download>📖 Baixar Versão DOC</a>
        <a href="https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.pdf" class="btn btn-primary" download>📄 Baixar Versão PDF</a>
    </p>
</div>

"@

# 4. Parsing Logic
# Normalize separators to a unique string "||SPLIT||"
# Variations: "....", "…", "<p>....</p>", etc.
$CleanHtml = $HtmlContent -replace '(?s)<!-- wp:separator.*?<!-- /wp:separator -->', '||SPLIT||' 
$CleanHtml = $CleanHtml -replace '\.\.\.\.', '||SPLIT||'
$CleanHtml = $CleanHtml -replace '…', '||SPLIT||'
# Also handle WP blocks that act as visual separators if any (like hr)
# (Done above with wp:separator)

# Split into chunks
$Chunks = $CleanHtml -split '\|\|SPLIT\|\|'
$Counter = 1

foreach ($Chunk in $Chunks) {
    if ([string]::IsNullOrWhiteSpace($Chunk)) { continue }

    # Extract Audio(s)
    # Regex to find <audio ... src="..."> and associated <figcaption>
    # Note: A chunk might have multiple audios
    $AudioMatches = [regex]::Matches($Chunk, '(?is)<figure class="wp-block-audio">.*?<audio.*?src="(.*?)".*?</audio>.*?<figcaption.*?>(.*?)</figcaption>.*?</figure>')
    
    # If no audio, check if it's just a header section (like "HINO DA UMBANDA")
    # We will preserve H2/H3 headers
    if ($AudioMatches.Count -eq 0) {
        $HeaderMatch = [regex]::Match($Chunk, '(?is)<h([23]).*?>(.*?)</h\1>')
        if ($HeaderMatch.Success) {
            $HeaderText = Remove-HtmlTags $HeaderMatch.Groups[2].Value
            $MarkdownContent += "`n`n## $HeaderText`n"
            Write-Host "Added Section Header: $HeaderText" -ForegroundColor Magenta
        }
        continue
    }

    # If it has audio, it's a Ponto
    # Extract Lyrics: Everything that is NOT the audio figure tags, and basically paragraphs
    # Remove the audio figures from the chunk text to get lyrics
    $LyricsHtml = $Chunk -replace '(?is)<figure class="wp-block-audio">.*?</figure>', ''
    # Remove WP comments
    $LyricsHtml = $LyricsHtml -replace '(?s)<!--.*?-->', ''
    
    # Get cleanup lyrics lines
    $LyricsLines = @()
    # Find all paragraphs
    $PMatches = [regex]::Matches($LyricsHtml, '(?is)<p>(.*?)</p>')
    foreach ($m in $PMatches) {
        $Line = Remove-HtmlTags $m.Groups[1].Value
        if (-not [string]::IsNullOrWhiteSpace($Line) -and $Line -notmatch '^Download') {
            $LyricsLines += $Line
        }
    }

    if ($LyricsLines.Count -eq 0) { continue }

    # Title is the first line of lyrics usually
    $TitleText = $LyricsLines[0]
    $SlugTitle = Get-Slug $TitleText
    $SeqNum = "{0:D3}" -f $Counter

    $MarkdownContent += "`n`n### $SeqNum - $TitleText`n`n"
    
    # Add Lyrics
    foreach ($Line in $LyricsLines) {
        $MarkdownContent += "> $Line  `n"
    }
    $MarkdownContent += "`n"

    # Process Audios
    foreach ($Match in $AudioMatches) {
        $Src = $Match.Groups[1].Value
        $Caption = Remove-HtmlTags $Match.Groups[2].Value
        $Ext = [System.IO.Path]::GetExtension($Src).Split('?')[0]
        if (-not $Ext) { $Ext = ".ogg" } # Default to ogg if unknown
        
        $SlugVoice = Get-Slug $Caption
        if ([string]::IsNullOrWhiteSpace($SlugVoice)) { $SlugVoice = "unknown" }

        $Values = "v" # Version counter for this song if multiple
        $FileName = "$SeqNum-$SlugTitle-$SlugVoice$Ext"
        
        # Ensure unique filename in case of duplicate captions/slugs in same chunk
        $FileDest = Join-Path $AudioDir $FileName
        $v = 1
        while (Test-Path $FileDest) {
            $FileName = "$SeqNum-$SlugTitle-$SlugVoice-v$v$Ext"
            $FileDest = Join-Path $AudioDir $FileName
            $v++
        }

        # Download
        Write-Host "Downloading [$SeqNum] $FileName..." -NoNewline
        try {
            # Use curl or IWR. Using .NET WebClient for speed/simplicity
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($Src, $FileDest)
            Write-Host " OK" -ForegroundColor Green
            
            # Add Player to Markdown
            $MarkdownContent += "**$Caption**`n"
            $MarkdownContent += "<audio controls preload='none' style='width: 100%; margin-bottom: 20px;'>`n"
            $MarkdownContent += "  <source src='/assets/audio/$FileName' type='audio/ogg'>`n"
            $MarkdownContent += "  <source src='/assets/audio/$FileName' type='audio/mpeg'>`n"
            $MarkdownContent += "  Seu navegador não suporta o elemento de áudio.`n"
            $MarkdownContent += "</audio>`n`n"

        }
        catch {
            Write-Host " ERROR: $_" -ForegroundColor Red
            $MarkdownContent += "> *Erro ao baixar áudio: $Caption*`n`n"
        }
    }

    $Counter++
}

# 5. Save Markdown
Set-Content -Path $MdPath -Value $MarkdownContent -Encoding UTF8
Write-Host "Rebuild Complete! Saved to $MdPath" -ForegroundColor Green
