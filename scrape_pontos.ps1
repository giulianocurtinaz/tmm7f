$ErrorActionPreference = "Stop"

# Configuration
$url = "https://maemariaseteflechas.com.br/pontos-cantados2/"
$baseDir = Get-Location
$pagesDir = Join-Path $baseDir "pages"
$assetsAudioDir = Join-Path $baseDir "assets\audio"
$assetsImageDir = Join-Path $baseDir "assets\images"
$outputFile = Join-Path $pagesDir "pontos-cantados-2.md"
$sitePrefix = ""

# Create directories
if (-not (Test-Path $assetsAudioDir)) { New-Item -ItemType Directory -Force -Path $assetsAudioDir | Out-Null }
if (-not (Test-Path $assetsImageDir)) { New-Item -ItemType Directory -Force -Path $assetsImageDir | Out-Null }

function Normalize-Filename {
    param ([string]$filename)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    $ext = [System.IO.Path]::GetExtension($filename)
    
    $normalized = $name.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $cleanName = $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
    $cleanName = $cleanName.ToLower() -replace ' ', '-' -replace '[^a-z0-9\-]', ''
    
    return "$cleanName$($ext.ToLower())"
}

Write-Host "Fetching content from $url..."
try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    $content = $response.Content
}
catch {
    Write-Error "Failed to fetch URL: $_"
    exit 1
}

# Start building Markdown
$markdown = @()
$markdown += "---"
$markdown += "layout: page"
$markdown += "title: `"Pontos Cantados 2`""
$markdown += "permalink: /pontos-cantados2/"
$markdown += "---"
$markdown += ""

# Extract Content Area (basic heuristic: look for content after header or specific marker if possible, 
# otherwise assume H3s are the structure)
# We will split by <h3> tags to process sections
$sections = $content -split "(?i)<h3"

# Variable to track downloaded images to avoid duplicates
$downloadedImages = @{}

Write-Host "Processing $($sections.Count) sections..."

# Skip the first section (usually header/nav garbage before first h3)
for ($i = 1; $i -lt $sections.Count; $i++) {
    $section = $sections[$i]
    
    # 1. Extract Title (everything until </h3>)
    if ($section -match "(?s)(.*?)</h3>(.*)") {
        $titleRaw = $matches[1]
        $bodyRaw = $matches[2]
        
        # Clean title: Remove anything before the first > (attributes of h3), then remove HTML tags
        $title = [System.Net.WebUtility]::HtmlDecode($titleRaw)
        $title = $title -replace "^[^>]*>", "" # Remove attributes like class=".."
        $title = $title -replace "<[^>]+>", "" # Remove other tags
        $title = $title.Trim()
        
        if (-not [string]::IsNullOrWhiteSpace($title)) {
            $markdown += "### $title"
            $markdown += ""
            Write-Host "Found Point: $title"
            
            # Debug: Force write and print
            if ($i -eq 1) {
                Write-Host "--- DEBUG BODY START ---"
                Write-Host $bodyRaw.Substring(0, [math]::Min(500, $bodyRaw.Length))
                Write-Host "--- DEBUG BODY END ---"
                $debugPath = Join-Path $baseDir "debug_section_body.txt"
                $bodyRaw | Out-File -FilePath $debugPath -Force
                Write-Host "Wrote debug file to $debugPath"
            }

            # 2. Extract Audio
            # Patterns: src="...mp3" or href="...mp3"
            # Broader pattern: find http(s) link ending in audio extension
            $audioUrl = $null
            $newAudioName = $null # Initialize to null
            if ($bodyRaw -match '(https?://[^"''\s<>]+\.(?:mp3|ogg|wav))') {
                $audioUrl = $matches[1]
                $audioFilename = [System.IO.Path]::GetFileName($audioUrl)
                # Remove query params if picked up by regex (though [^"'\s<>] usually excludes them if clean, but let's be safe)
                if ($audioFilename -match "(.+\.(?:mp3|ogg|wav))\?") {
                    $audioFilename = $matches[1]
                }
                
                $newAudioName = Normalize-Filename $audioFilename
                $localAudioPath = Join-Path $assetsAudioDir $newAudioName
                
                # Download Audio
                if (-not (Test-Path $localAudioPath)) {
                    Write-Host "  Downloading audio: $audioFilename -> $newAudioName"
                    try {
                        Invoke-WebRequest -Uri $audioUrl -OutFile $localAudioPath -ErrorAction SilentlyContinue
                    }
                    catch {
                        Write-Warning "  Failed to download audio: $audioUrl"
                    }
                }
                else {
                    Write-Host "  Audio exists, skipping: $newAudioName"
                }

                # Start Audio Player HTML (will be closed after lyrics)
                $markdown += "<audio controls>"
                $markdown += "  <source src=`"$sitePrefix/assets/audio/$newAudioName`" type=`"audio/ogg`">"
                $markdown += "</audio>"
                $markdown += ""
            }

            # 3. Process Images in this section
            $imageMatches = [Regex]::Matches($bodyRaw, '(?i)<img[^>]+src="([^"]+)"')
            foreach ($imgMatch in $imageMatches) {
                $imgUrl = $imgMatch.Groups[1].Value
                if ($imgUrl -notmatch "pixel|loader|emoji|gravatar") {
                    # Skip common trash
                    $imgName = [System.IO.Path]::GetFileName($imgUrl)
                    $newImgName = Normalize-Filename $imgName
                    $localImgPath = Join-Path $assetsImageDir $newImgName
                        
                    if (-not ($downloadedImages.ContainsKey($newImgName))) {
                        if (-not (Test-Path $localImgPath)) {
                            Write-Host "  Downloading image: $imgName -> $newImgName"
                            try {
                                Invoke-WebRequest -Uri $imgUrl -OutFile $localImgPath
                            }
                            catch {
                                Write-Warning "  Failed to download image: $imgUrl"
                            }
                        }
                        $downloadedImages[$newImgName] = $true
                    }
                        
                    $markdown += "![]($sitePrefix/assets/images/$newImgName)"
                    $markdown += ""
                }
            }

            # 4. Extract Lyrics (Text)
            # Remove scripts, styles
            $lyrics = $bodyRaw -replace "(?is)<script.*?>.*?</script>", ""
            $lyrics = $lyrics -replace "(?is)<style.*?>.*?</style>", ""
            # Replace <br> and <p> with newlines
            $lyrics = $lyrics -replace "(?i)<br\s*/?>", "`n"
            $lyrics = $lyrics -replace "(?i)</p>", "`n`n"
            # Remove all other tags
            $lyrics = $lyrics -replace "<[^>]+>", ""
            # Decode HTML entities
            $lyrics = [System.Net.WebUtility]::HtmlDecode($lyrics).Trim()
            
            # Filter out generic text "Compartilhe isso", "Curtir isso"
            $lyricsLines = $lyrics -split "`n"
            $cleanLyrics = @()
            foreach ($line in $lyricsLines) {
                $l = $line.Trim()
                if ($l -ne "" -and $l -notmatch "Compartilhe isso" -and $l -notmatch "Curtir isso:") {
                    $cleanLyrics += $l
                }
            }
            
            $markdown += ($cleanLyrics -join "`n")
            $markdown += ""
            
            # Add separator
            $markdown += "---"
            $markdown += ""
        }
    }
}

$markdown | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Markdown generated at: $outputFile"
