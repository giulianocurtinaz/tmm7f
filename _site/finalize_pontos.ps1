$ErrorActionPreference = "Stop"

# Paths
$baseDir = "C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp"
$antigosPath = Join-Path $baseDir "pontoscantados_antigos.html"
$livePath = Join-Path $baseDir "debug_page.html"
$audioDir = Join-Path $baseDir "assets\audio"
$docsDir = Join-Path $baseDir "assets\docs"
$outputFile = Join-Path $baseDir "pontos-cantados.md"
$siteBaseUrl = "{{ site.baseurl }}"

# Ensure directories
if (-not (Test-Path $audioDir)) { New-Item -ItemType Directory -Force -Path $audioDir | Out-Null }
if (-not (Test-Path $docsDir)) { New-Item -ItemType Directory -Force -Path $docsDir | Out-Null }

Write-Host "Reading files..."
# Read raw content
$antigosContent = Get-Content $antigosPath -Raw -Encoding UTF8
$liveContent = Get-Content $livePath -Raw -Encoding UTF8

if (-not $liveContent) {
    Write-Error "debug_page.html is empty using scraping?"
}

# Helper to normalize text for matching
function Normalize-Text {
    param ([string]$text)
    if ([string]::IsNullOrEmpty($text)) { return "" }
    # Decode HTML
    $t = [System.Net.WebUtility]::HtmlDecode($text)
    # Remove tags
    $t = $t -replace '<[^>]+>', ' '
    # Normalize whitespace
    $t = $t -replace '\s+', ' '
    return $t.Trim()
}

function Get-FriendlyName {
    param ([string]$name)
    $normalized = $name.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    return $sb.ToString().ToLower() -replace ' ', '-' -replace '[^a-z0-9\-]', ''
}

# 1. Parse Antigos File to get Songs Structure
Write-Host "Parsing structure from Antigos file..."
$songs = @()
$antigosSections = $antigosContent -split '<div class="musica">'

foreach ($section in $antigosSections) {
    if ($section -match '(?is)<h3>(.*?)</h3>') {
        $titleRaw = $matches[1]
        $titleClean = Normalize-Text $titleRaw
        
        # Extract Lyrics
        $lyricsRaw = ""
        if ($section -match '(?is)<div class="letra">(.*?)</div>') {
            $lyricsRaw = $matches[1]
        }
        
        # Clean lyrics for markdown
        $lyricsMd = $lyricsRaw -replace '(?i)<br\s*/?>', "`n"
        $lyricsMd = $lyricsMd -replace '(?i)</p>', "`n`n"
        $lyricsMd = $lyricsMd -replace '<[^>]+>', ''
        $lyricsMd = [System.Net.WebUtility]::HtmlDecode($lyricsMd).Trim()
        
        # Snippet for matching
        $matchSnippet = $lyricsMd -replace '\s+', '' 
        if ($matchSnippet.Length -gt 50) { $matchSnippet = $matchSnippet.Substring(0, 50) }
        
        $songs += [PSCustomObject]@{
            Title        = $titleClean
            LyricsMd     = $lyricsMd
            MatchSnippet = $matchSnippet
        }
    }
}
Write-Host "Found $($songs.Count) songs in Antigos file."

# 2. Map Audio from Live Content
# We will treat live content as a giant string and search for the snippets.
# Normalizing live content for search (removing tags but keeping structure roughly? No, better to keep tags for src extraction)
# We need to find the INDEX of the lyrics match, then search forward for .mp3/.ogg urls
# But we must be careful not to overshoot into the NEXT song.

# To simplify, let's normalize the live content STRIPPING TAGS for the SEARCH, but keep a mapping to original? Hard.
# Better: Just search in the raw string. The snippet should exist roughly.
# $matchSnippet might need to be regex-escaped and allow for tags in between chars?
# Actually, the live file has `<p>Line<br>Line</p>`. 
# So if I stripped tags from my search snippet, I should strip tags from live content window?

# Strategy: regex match the snippet with liberal whitespace/tag allowance.
# Snippet: "Refletiu a luz Divina" -> Regex: "Refletiu\s*(?:<[^>]+>\s*)*a\s*(?:<[^>]+>\s*)*luz..."
# This is getting complicated.

# Simpler Strategy:
# Identify all Audio URLs in Live File and their context (preceding text).
# For each song in Antigos, find the best matching Audio context.

$audioCandidates = @()
# Find all <audio> or <figure> blocks with audio
$audioMatches = [regex]::Matches($liveContent, '(?is)(<audio[^>]+src="([^"]+)"[^>]*>)(?:.*?<figcaption.*?>(.*?)</figcaption>)?')

# We need to knowing WHERE they are to find preceding text.
foreach ($m in $audioMatches) {
    $url = $m.Groups[2].Value
    $label = $m.Groups[3].Value
    $index = $m.Index
    
    # Get preceding 1000 chars
    $start = [math]::Max(0, $index - 2000)
    $context = $liveContent.Substring($start, $index - $start)
    $context = Normalize-Text $context # Remove tags, etc.
    
    if ($url -match '\.(mp3|ogg)$') {
        $audioCandidates += [PSCustomObject]@{
            Url     = $url
            Label   = $label
            Context = $context
        }
    }
}

Write-Host "Found $($audioCandidates.Count) audio candidates in Live file."

# 3. Build Markdown
$markdown = @()
$markdown += "---"
$markdown += "layout: page"
$markdown += "title: Pontos Cantados"
$markdown += "---"
$markdown += ""
$markdown += "Letras e áudios dos nossos pontos cantados."
$markdown += "### Livro de Pontos"
$markdown += "- [Baixar Pontos_Cantados DOC]($siteBaseUrl/assets/docs/pontos_cantados.docx)"
$markdown += "- [Baixar Pontos_Cantados PDF]($siteBaseUrl/assets/docs/pontos_cantados.pdf)"
$markdown += ""
$markdown += "---"
$markdown += ""

$songNumber = 1

foreach ($song in $songs) {
    $prefix = "{0:D3}" -f $songNumber
    $markdown += "### $prefix - $($song.Title)"
    $markdown += ""
    $markdown += $song.LyricsMd
    $markdown += ""
    
    # Find matching audios
    # We look for audios whose Context contains the song's MatchSnippet
    # NOTE: Since context is preceding 2000 chars, it should contain the lyrics.
    # We should filter by "closest" or uniqueness?
    # If multiple audios match the same lyrics, they are likely versions of the same song.
    
    # We clean the match snippet specifically for context search
    $searchPhrase = $song.LyricsMd.Split("`n")[0].Trim() # Use first line of lyrics
    if ($searchPhrase.Length -gt 20) { $searchPhrase = $searchPhrase.Substring(0, 20) }
    $searchPhrase = $searchPhrase -replace '[^\w\s]', '' # Remove punctuation
    
    $myAudios = @()
    foreach ($cand in $audioCandidates) {
        if ($cand.Context -match [regex]::Escape($searchPhrase)) {
            $myAudios += $cand
        }
    }
    
    # Deduplicate by URL
    $uniqueAudios = $myAudios | Sort-Object Url -Unique
    
    $vIndex = 1
    foreach ($audio in $uniqueAudios) {
        $ext = [System.IO.Path]::GetExtension($audio.Url).ToLower()
        $safeTitle = Get-FriendlyName $song.Title
        $newFilename = "$prefix-$safeTitle-v$vIndex$ext"
        $localPath = Join-Path $audioDir $newFilename
        
        # Download
        if (-not (Test-Path $localPath)) {
            Write-Host "  [$prefix] Downloading $newFilename"
            try {
                Invoke-WebRequest -Uri $audio.Url -OutFile $localPath -ErrorAction SilentlyContinue
            }
            catch {
                Write-Warning "Failed to download $($audio.Url)"
            }
        }
        
        # Label
        $label = if ($audio.Label) { $audio.Label } else { "Versão $vIndex" }
        $label = Normalize-Text $label
        
        $markdown += "**$label**"
        $mime = if ($ext -eq ".mp3") { "audio/mpeg" } else { "audio/ogg" }
        
        $markdown += "<audio controls>`n  <source src=`"$siteBaseUrl/assets/audio/$newFilename`" type=`"$mime`">`n  Seu navegador não suporta o player de áudio.`n</audio>"
        $markdown += ""
        
        $vIndex++
    }
    
    $markdown += "---"
    $markdown += ""
    $songNumber++
}

$markdown | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Generated $outputFile"

