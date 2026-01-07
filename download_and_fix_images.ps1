$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$xmlPath = Join-Path $baseDir "meusite.xml"
$imagesDir = Join-Path $baseDir "assets\images"
$postsDir = Join-Path $baseDir "_posts"
$pagesDir = Join-Path $baseDir "pages"

# Ensure images dir exists
if (-not (Test-Path $imagesDir)) { New-Item -Path $imagesDir -ItemType Directory | Out-Null }

# 1. Load XML
Write-Host "Loading XML..."
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load($xmlPath)
$ns = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$ns.AddNamespace("wp", "http://wordpress.org/export/1.2/")

# Select all attachments
$items = $xmlDoc.SelectNodes("//item[wp:post_type='attachment']", $ns)

# Map: OriginalURL -> NewLocalFilename (relative to assets/images)
# Map: BaseName (no ext) -> List of NewNames (for cleanup safety?) 
# Actually simple cleanup: if we download '2025-10-9.jpg', we check if '9.jpg' exists and delete it.
$urlToNewName = @{}

# Web Client for downloads
$webClient = New-Object System.Net.WebClient

# 2. Extract and Download
Write-Host "Found $($items.Count) attachments. Starting download..."

foreach ($item in $items) {
    try {
        $url = $item.SelectSingleNode("wp:attachment_url", $ns).InnerText
        if (-not $url) { $url = $item.SelectSingleNode("guid").InnerText }
        
        if ($url) {
            # Extract Date and Name
            # Pattern: .../YYYY/MM/filename.ext
            if ($url -match "/(\d{4})/(\d{2})/(.+)$") {
                $year = $matches[1]
                $month = $matches[2]
                $rawName = $matches[3]
                
                # Sanitize raw name (remove query strings)
                $rawName = $rawName -replace "\?.*$", ""
                
                # Normalize filename part
                $fileName = [System.IO.Path]::GetFileName($rawName)
                $cleanName = $fileName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-\.]', ''
                # Remove accents?
                $cleanName = $cleanName.Normalize([System.Text.NormalizationForm]::FormD)
                $sb = New-Object System.Text.StringBuilder
                foreach ($c in $cleanName.ToCharArray()) {
                    if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
                        [void]$sb.Append($c)
                    }
                }
                $cleanName = $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
                
                
                $newName = "$year-$month-$cleanName"
                $localPath = Join-Path $imagesDir $newName
                
                # Map URL to new name (we will use this for MD updates)
                $urlToNewName[$url] = $newName
                
                # Also map the "clean" url without query string if different
                $cleanUrl = $url -replace "\?.*$", ""
                if ($cleanUrl -ne $url) { $urlToNewName[$cleanUrl] = $newName }

                # Download
                if (Test-Path $localPath) {
                    Write-Host "Skipping existing: $newName"
                }
                else {
                    Write-Host "Downloading: $url -> $newName"
                    try {
                        $webClient.DownloadFile($url, $localPath)
                    }
                    catch {
                        Write-Warning "Failed to download $url : $_"
                    }
                }
                
                # Cleanup Generic "Conflict" File
                # If we just created '2025-10-9.jpg' (from 9.jpg), delete '9.jpg' if exists
                $genericName = $cleanName
                $genericPath = Join-Path $imagesDir $genericName
                if (Test-Path $genericPath) {
                    # Safety check: Prevent deleting if genericName IS the newName (unlikely with prefix)
                    if ($genericPath -ne $localPath) {
                        Write-Host "Deleting generic conflict file: $genericName"
                        Remove-Item $genericPath -Force
                    }
                }
            }
        }
    }
    catch {
        Write-Warning "Error processing item: $_"
    }
}

# 3. Update Markdown Files
Write-Host "Updating Markdown files..."

$mdFiles = Get-ChildItem -Path $postsDir, $pagesDir -Filter "*.md" -Recurse

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    
    # We need to replace links. 
    # Current links might be:
    # 1. To old HTTP URLs (if rebuild didn't fully catch them or if using Original XML content)
    # 2. To local /assets/images/generic.jpg (from previous attempts)
    
    # Issue: The current markdown on disk (from previous step) already has replaced links with local paths like /assets/images/9.jpg.
    # But we don't know easily which "9.jpg" that was (2020 or 2025?).
    # STRATEGY: 
    # The previous rebuild script used the XML structure to generating MD. 
    # If we iterate the XML attachments again, match the URL to the Post content?
    # NO, the MD file has "9.jpg". We deleted "9.jpg". Now the link is broken.
    # We need to find what URL "9.jpg" came from.
    # But the MD file *content* might still contain the original URL in some versions?
    # IF the previous step was "Rebuild Site from XML", the MD files were generated fresh from XML.
    # The XML has the *Original* URL.
    # The "Rebuild" script replaced that URL with a normalized name.
    
    # CRITICAL: The user's prompt implies we are fixing the files.
    # If the files currently have `/assets/images/9.jpg`, we can't easily distinguish.
    # BUT, the "Rebuild from XML" script *just ran*. It successfully generated files with logic:
    # `if ($url -match ...) { return "(/assets/images/$norm)" }`
    # So the current MD files have generic names.
    
    # RE-REBUILDING might be safer?
    # Or matches based on context?
    # Actually, the user says "Vinculação nos Posts: Atualizar todos os arquivos ... para que apontem para esses novos nomes".
    # Since I just ran a rebuild that put "generic" names, maybe I should just run this replacement logic on the *raw XML content* again and regenerate the files?
    # Modifying existing MD files is hard because we lost the date context in the file content.
    # EXCEPT: The XML export is the source of truth.
    # I should re-generate the MD files from XML *again* with the new naming logic.
    # That guarantees correctness.
    
    # However, the user request says "Atualizar todos os arquivos .md ...".
    # I will assume re-generating is the best way to "update" them accurately.
    # Wait, the user prompt implies existing files.
    # If I just do regex replacement on links:
    # `![](/assets/images/9.jpg)` -> Which one?
    # I cannot know.
    # THEREFORE: I MUST regenerate the markdown from the XML to get the relationship between Post and Image URL back.
    # The XML contains the HTML content with the *Original URL* (e.g. `http://.../2025/10/9.jpg`).
    # My new logic will map `http://.../2025/10/9.jpg` -> `2025-10-9.jpg`.
    # So regeneration is the only robust path.
}

# 3b. REGENERATE MARKDOWN (Instead of identifying/patching)
Write-Host "Regenerating Markdown files content from XML to ensure correct linking..."

function Fix-Encoding-Simple {
    param ([string]$text)
    if ([string]::IsNullOrEmpty($text)) { return "" }
    $out = $text.Replace([string][char]0xC3 + [string][char]0xA9, "é")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xA3, "ã")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xA1, "á")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xA2, "â")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xAA, "ê")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xB3, "ó")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xB4, "ô")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xB5, "õ")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xBA, "ú")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xA7, "ç")
    $out = $out.Replace([string][char]0xC3 + [string][char]0x20, "à")
    $out = $out.Replace([string][char]0xC3 + [string][char]0xAD, "í")
    $out = $out.Replace([string][char]0x01DC, "ã")
    $out = $out.Replace([string][char]0x01ED, "á")
    $out = $out.Replace([string][char]0x01F8, "é")
    $out = $out.Replace([string][char]0xFFFD, "ç")
    return $out.Replace("Mǜe", "Mãe")
}

function Convert-HtmlToMarkdown {
    param ([string]$html)
    if ([string]::IsNullOrEmpty($html)) { return "" }
    $md = $html -replace "(?i)<br\s*/?>", "`n"
    $md = $md -replace "(?i)<p[^>]*>", "`n`n"
    $md = $md -replace "(?i)</p>", ""
    $md = $md -replace "(?i)<strong>|<b>", "**"
    $md = $md -replace "(?i)</strong>|</b>", "**"
    $md = $md -replace "(?i)<em>|<i>", "*"
    $md = $md -replace "(?i)</em>|</i>", "*"
    $md = $md -replace "(?i)<h([1-6])>(.*?)</h\1>", "`n`n# `$2`n"
    $md = [Regex]::Replace($md, '(?i)<a[^>]+href="([^"]+)"[^>]*>(.*?)</a>', { param($m); "[$($m.Groups[2].Value)]($($m.Groups[1].Value))" })
    $md = [Regex]::Replace($md, '(?i)<img[^>]+src="([^"]+)"[^>]*>', { param($m); "![]($($m.Groups[1].Value))" })
    $md = $md -replace "<[^>]+>", ""
    $md = [System.Net.WebUtility]::HtmlDecode($md)
    return $md.Trim()
}

$xmlItems = $xmlDoc.SelectNodes("//item")

# Attachment ID to URL map for CoverImages
$attIdToUrl = @{}
foreach ($item in $xmlItems) {
    if ($item.SelectSingleNode("wp:post_type", $ns).InnerText -eq "attachment") {
        $id = $item.SelectSingleNode("wp:post_id", $ns).InnerText
        $url = $item.SelectSingleNode("wp:attachment_url", $ns).InnerText
        if (-not $url) { $url = $item.SelectSingleNode("guid").InnerText }
        if ($url) { $attIdToUrl[$id] = $url }
    }
}

foreach ($item in $xmlItems) {
    $pt = $item.SelectSingleNode("wp:post_type", $ns).InnerText
    if ($pt -eq "post" -or $pt -eq "page") {
        # Extract metadata
        $title = Fix-Encoding-Simple $item.SelectSingleNode("title").InnerText
        $date = $item.SelectSingleNode("wp:post_date", $ns).InnerText
        $slug = $item.SelectSingleNode("wp:post_name", $ns).InnerText
        $contentHtml = $item.SelectSingleNode("content:encoded", $ns).InnerText
        
        $dateObj = [datetime]::Parse($date)
        $dateStr = $dateObj.ToString("yyyy-MM-dd")
        if (-not $slug) { $slug = "$pt-$($dateObj.Ticks)" }
        $filename = if ($pt -eq "post") { "$dateStr-$slug.md" } else { "$slug.md" }
        $targetPath = if ($pt -eq "post") { Join-Path $postsDir $filename } else { Join-Path $pagesDir $filename }
        
        # Cover Image URL
        $coverImage = $null
        $thumbIdNode = $item.SelectSingleNode("wp:postmeta[wp:meta_key='_thumbnail_id']/wp:meta_value", $ns)
        if ($thumbIdNode) {
            $tid = $thumbIdNode.InnerText
            if ($attIdToUrl.ContainsKey($tid)) {
                $cUrl = $attIdToUrl[$tid]
                if ($urlToNewName.ContainsKey($cUrl)) {
                    $coverImage = "/assets/images/" + $urlToNewName[$cUrl]
                }
            }
        }
        
        # Convert Content
        $contentMd = Convert-HtmlToMarkdown $contentHtml
        $contentMd = Fix-Encoding-Simple $contentMd
        
        # Replace Links
        # We need to find URLs in MD and map them.
        # Format: (http://...)
        $contentMd = [Regex]::Replace($contentMd, '\((https?://[^)]+)\)', {
                param($m)
                $foundUrl = $m.Groups[1].Value
                # Try exact match
                if ($urlToNewName.ContainsKey($foundUrl)) {
                    return "(/assets/images/" + $urlToNewName[$foundUrl] + ")"
                }
                # Try stripped match
                $cleanMatches = $foundUrl -replace "\?.*$", ""
                if ($urlToNewName.ContainsKey($cleanMatches)) {
                    return "(/assets/images/" + $urlToNewName[$cleanMatches] + ")"
                }
                # Fallback: if we haven't downloaded it but it looks like a WP upload, try normal processing
                # Extract Date and Name logic again?
                if ($foundUrl -match "/(\d{4})/(\d{2})/(.+)$") {
                    $y = $matches[1]; $mo = $matches[2]; $n = $matches[3]
                    $n = $n -replace "\?.*$", ""
                    $n = [System.IO.Path]::GetFileName($n).ToLower()
                    # Normalize name again to guess?
                    $n = $n.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-\.]', ''
                    # This guess might be wrong if we didn't download it.
                    # Just return original if not found in map.
                }
                return "($foundUrl)"
            })
        
        # Write File
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("layout: $pt")
        [void]$sb.AppendLine("title: `"$title`"")
        [void]$sb.AppendLine("date: $dateStr")
        foreach ($c in $item.SelectNodes("category[@domain='category']")) {
            if ($c.InnerText -ne "Sem categoria") {
                if (-not $sb.ToString().Contains("categories:")) { [void]$sb.AppendLine("categories:") }
                [void]$sb.AppendLine("  - `"$($c.InnerText)`"")
            }
        }
        if ($coverImage) { [void]$sb.AppendLine("coverImage: `"$coverImage`"") }
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine($contentMd)
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($targetPath, $sb.ToString(), $utf8NoBom)
    }
}

Write-Host "Done."
