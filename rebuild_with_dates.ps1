$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$xmlPath = Join-Path $baseDir "meusite.xml"
$zipPath = Join-Path $baseDir "meusite.zip"
$tempDir = Join-Path $baseDir "_temp_extract"
$postsDir = Join-Path $baseDir "_posts"
$pagesDir = Join-Path $baseDir "pages"
$assetsDir = Join-Path $baseDir "assets\images"

# 1. Extract Zip to recover original structure
Write-Host "Extracting meusite.zip..."
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

# 2. Helpers
function Get-NormalizedName {
    param ([string]$filename)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    $ext = [System.IO.Path]::GetExtension($filename)
    $text = $name.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $text.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $text = $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
    $cleanName = $text.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-]', ''
    return "$cleanName$($ext.ToLower())"
}

function Fix-Encoding {
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
    return $out
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

# 3. Load XML
Write-Host "Loading XML..."
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load($xmlPath)
$ns = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$ns.AddNamespace("wp", "http://wordpress.org/export/1.2/")
$ns.AddNamespace("content", "http://purl.org/rss/1.0/modules/content/")
$items = $xmlDoc.SelectNodes("//item")

# 4. Process Images/Attachments (Rename and Move)
Write-Host "Processing Attachments..."
$attachmentMap = @{} # ID -> "/tmm7f/assets/images/YYYY-MM-name.jpg"
$urlToNewPath = @{}  # OriginalURL -> "/tmm7f/assets/images/YYYY-MM-name.jpg"

foreach ($item in $items) {
    if ($item.SelectSingleNode("wp:post_type", $ns).InnerText -eq "attachment") {
        $id = $item.SelectSingleNode("wp:post_id", $ns).InnerText
        $url = $item.SelectSingleNode("wp:attachment_url", $ns).InnerText
        if (-not $url) { $url = $item.SelectSingleNode("guid").InnerText }
        
        if ($url) {
            # Try to parse date from URL structure .../uploads/YYYY/MM/file.jpg
            # Regex to find YYYY/MM
            if ($url -match "/(\d{4})/(\d{2})/(.+)$") {
                $year = $matches[1]
                $month = $matches[2]
                $rawName = $matches[3] # This might have query strings or extra encoding
                
                # Cleanup raw name
                $rawName = [System.IO.Path]::GetFileName($rawName)
                if ($rawName -match "(.+?)\?") { $rawName = $matches[1] } # Strip query
                
                # Source Path in Extract
                # structure usually: wp-content/uploads/YYYY/MM/file
                # We need to find where it is in $tempDir
                # Let's search recursively in tempDir for the file to be safe, or construct path
                
                # Construct Normalized Target Name: YYYY-MM-normalizedName
                $normName = Get-NormalizedName $rawName
                $targetName = "$year-$month-$normName"
                $targetPath = Join-Path $assetsDir $targetName
                
                # Copy/Move Logic
                # Search for source file
                # The zip might have different root folder name.
                # simpler to search by name in temp dir?
                # But duplicates have same name. We need to respect YYYY/MM structure if present in zip.
                
                $expectedSourcePath = Join-Path $tempDir "wp-content\uploads\$year\$month\$rawName"
                # Handle URL encoding in filename on disk? URL might be encoded, disk might represent differently.
                # Let's try direct path first.
                
                if (-not (Test-Path $expectedSourcePath)) {
                    # Try finding it broadly? Or try decoded name?
                    $decodedName = [System.Net.WebUtility]::UrlDecode($rawName)
                    $expectedSourcePath = Join-Path $tempDir "wp-content\uploads\$year\$month\$decodedName"
                }
                
                if (Test-Path $expectedSourcePath) {
                    Copy-Item -Path $expectedSourcePath -Destination $targetPath -Force
                    $finalWebPath = "/tmm7f/assets/images/$targetName"
                    $attachmentMap[$id] = $finalWebPath
                    $urlToNewPath[$url] = $finalWebPath
                    # Also map simpler URL without query string
                    $cleanUrl = $url -replace "\?.*$", ""
                    if ($cleanUrl -ne $url) { $urlToNewPath[$cleanUrl] = $finalWebPath }
                }
                else {
                    Write-Warning "Source file not found for $url in zip structure. Checking if exists locally in assets..."
                    # Check if we have a file with '$normName' in assets/images (fallback)
                    # Use existing if found, but rename to date-prefixed
                    $existingAsset = Join-Path $assetsDir $normName
                    if (Test-Path $existingAsset) {
                        Copy-Item -Path $existingAsset -Destination $targetPath -Force
                        $finalWebPath = "/tmm7f/assets/images/$targetName"
                        $attachmentMap[$id] = $finalWebPath
                        $urlToNewPath[$url] = $finalWebPath
                    }
                    else {
                        # Maybe it's already renamed?
                        if (Test-Path $targetPath) {
                            $finalWebPath = "/tmm7f/assets/images/$targetName"
                            $attachmentMap[$id] = $finalWebPath
                            $urlToNewPath[$url] = $finalWebPath
                        }
                    }
                }
            }
            else {
                # Setup for images that don't match date pattern (rare in WP)
                # Just normalize
                $fname = [System.IO.Path]::GetFileName($url)
                $norm = Get-NormalizedName $fname
                $targetPath = Join-Path $assetsDir $norm
                $finalWebPath = "/tmm7f/assets/images/$norm"
                $attachmentMap[$id] = $finalWebPath
                $urlToNewPath[$url] = $finalWebPath
            }
        }
    }
}

# 5. Rebuild MD Files
Write-Host "Rebuilding Content..."
if (Test-Path $postsDir) { Remove-Item (Join-Path $postsDir "*.md") -Force -ErrorAction SilentlyContinue }
else { New-Item -Path $postsDir -ItemType Directory | Out-Null }
if (Test-Path $pagesDir) { Remove-Item (Join-Path $pagesDir "*.md") -Force -ErrorAction SilentlyContinue }
else { New-Item -Path $pagesDir -ItemType Directory | Out-Null }

foreach ($item in $items) {
    if ($item.SelectSingleNode("wp:post_type", $ns).InnerText -in @("post", "page")) {
        $pt = $item.SelectSingleNode("wp:post_type", $ns).InnerText
        $title = Fix-Encoding $item.SelectSingleNode("title").InnerText
        $date = $item.SelectSingleNode("wp:post_date", $ns).InnerText
        $slug = $item.SelectSingleNode("wp:post_name", $ns).InnerText
        $contentHtml = $item.SelectSingleNode("content:encoded", $ns).InnerText
        
        $dateObj = [datetime]::Parse($date)
        $dateStr = $dateObj.ToString("yyyy-MM-dd")
        if (-not $slug) { $slug = "$pt-$($dateObj.Ticks)" }
        
        $filename = if ($pt -eq "post") { "$dateStr-$slug.md" } else { "$slug.md" }
        $targetPath = if ($pt -eq "post") { Join-Path $postsDir $filename } else { Join-Path $pagesDir $filename }
        $layout = $pt
        
        # Cover Image
        $coverImage = $null
        $thumbIdNode = $item.SelectSingleNode("wp:postmeta[wp:meta_key='_thumbnail_id']/wp:meta_value", $ns)
        if ($thumbIdNode) {
            $tid = $thumbIdNode.InnerText
            if ($attachmentMap.ContainsKey($tid)) { $coverImage = $attachmentMap[$tid] }
        }
        
        $contentMd = Convert-HtmlToMarkdown $contentHtml
        $contentMd = Fix-Encoding $contentMd
        
        # Replace Links using URL Map or Regex fallback
        # First try precise mapping
        # Regex to find (http...)
        $contentMd = [Regex]::Replace($contentMd, '\((https?://[^)]+)\)', {
                param($m)
                $url = $m.Groups[1].Value
                # Try exact match
                if ($urlToNewPath.ContainsKey($url)) { return "(" + $urlToNewPath[$url] + ")" }
                # Try cleaning query string
                $cleanStart = $url -replace "\?.*$", ""
                if ($urlToNewPath.ContainsKey($cleanStart)) { return "(" + $urlToNewPath[$cleanStart] + ")" }
            
                # Fallback: Date logic extraction if map failed?
                if ($url -match "/(\d{4})/(\d{2})/(.+)$") {
                    $y = $matches[1]; $m_ = $matches[2]; $n = $matches[3]
                    $n = [System.IO.Path]::GetFileName($n)
                    if ($n -match "(.+?)\?") { $n = $matches[1] }
                    $norm = Get-NormalizedName $n
                    return "(/tmm7f/assets/images/$y-$m_-$norm)"
                }
                return "($url)"
            })
        
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("layout: $layout")
        [void]$sb.AppendLine("title: `"$title`"")
        [void]$sb.AppendLine("date: $dateStr")
        if ($item.SelectNodes("category[@domain='category']").Count -gt 0) {
            [void]$sb.AppendLine("categories:")
            foreach ($c in $item.SelectNodes("category[@domain='category']")) {
                if ($c.InnerText -ne "Sem categoria") { [void]$sb.AppendLine("  - `"$($c.InnerText)`"") }
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

# 6. Cleanup Temp
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done."
