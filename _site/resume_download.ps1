$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$xmlPath = Join-Path $baseDir "meusite.xml"
$imagesDir = Join-Path $baseDir "assets\images"
$postsDir = Join-Path $baseDir "_posts"
$pagesDir = Join-Path $baseDir "pages"
$stateFile = Join-Path $baseDir "download_state.json"

# Settings
$BatchSize = 20
$SleepSeconds = 1 # Be nice to the server

# Ensure dirs exist
if (-not (Test-Path $imagesDir)) { New-Item -Path $imagesDir -ItemType Directory | Out-Null }

# Helper: Fix specific encoding issues
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
    return $out.Replace("Mǜe", "Mãe")
}

# Helper: Convert HTML to Markdown
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

# 1. Load XML
Write-Host "Loading XML..."
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load($xmlPath)
$ns = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$ns.AddNamespace("wp", "http://wordpress.org/export/1.2/")
$ns.AddNamespace("content", "http://purl.org/rss/1.0/modules/content/")

# 2. Identify Attachments
Write-Host "Analyzing attachments..."
$items = $xmlDoc.SelectNodes("//item[wp:post_type='attachment']", $ns)
$allAttachments = @()

foreach ($item in $items) {
    $url = $item.SelectSingleNode("wp:attachment_url", $ns).InnerText
    if (-not $url) { $url = $item.SelectSingleNode("guid").InnerText }
    
    # Skipping Logic: Audio
    if ($url -match "\.ogg$") { continue }
    
    # Priority Logic: Images first (though here we just add all non-ogg)
    if ($url) {
        $allAttachments += @{
            Node = $item
            Url  = $url
        }
    }
}

# Sort: images (.jpg, .png) first, others later
$allAttachments = $allAttachments | Sort-Object -Property @{Expression = {
        if ($_.Url -match "\.(jpg|png)$") { 0 } else { 1 }
    }
}

Write-Host "Total Attachments (filtered): $($allAttachments.Count)"

# 3. Load/Init State
$state = @{ LastIndex = 0; DownloadedMap = @{} }
if (Test-Path $stateFile) {
    try {
        $json = Get-Content $stateFile -Raw | ConvertFrom-Json
        $state.LastIndex = $json.LastIndex
        # Convert PSCustomObject map back to Hashtable
        if ($json.DownloadedMap) {
            $json.DownloadedMap.PSObject.Properties | ForEach-Object {
                $state.DownloadedMap[$_.Name] = $_.Value
            }
        }
    }
    catch {
        Write-Warning "Could not load state file. Starting fresh."
    }
}

# 4. Batch Processing
$startIndex = $state.LastIndex
if ($startIndex -ge $allAttachments.Count) {
    Write-Host "All attachments processed."
    exit
}

$endIndex = [Math]::Min($startIndex + $BatchSize - 1, $allAttachments.Count - 1)
Write-Host "Processing batch: $startIndex to $endIndex"

$webClient = New-Object System.Net.WebClient

for ($i = $startIndex; $i -le $endIndex; $i++) {
    $att = $allAttachments[$i]
    $url = $att.Url
    
    # Naming Logic
    # Pattern: .../YYYY/MM/filename.ext
    if ($url -match "/(\d{4})/(\d{2})/(.+)$") {
        $year = $matches[1]
        $month = $matches[2]
        $rawName = $matches[3]
        $rawName = $rawName -replace "\?.*$", ""
        
        $fileName = [System.IO.Path]::GetFileName($rawName)
        $cleanName = $fileName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-\.]', ''
        
        # Simple accent removal (expanded as needed)
        $cleanName = $cleanName.Replace("ã", "a").Replace("á", "a").Replace("é", "e").Replace("ç", "c")
        
        $newName = "$year-$month-$cleanName"
        $localPath = Join-Path $imagesDir $newName
        
        # Store mapping
        $state.DownloadedMap[$url] = $newName
        $cleanUrl = $url -replace "\?.*$", ""
        if ($cleanUrl -ne $url) { $state.DownloadedMap[$cleanUrl] = $newName }
        
        # Download
        if (Test-Path $localPath) {
            Write-Host "[$i] Exists: $newName"
        }
        else {
            Write-Host "[$i] Downloading: $newName"
            try {
                $webClient.DownloadFile($url, $localPath)
                Start-Sleep -Seconds $SleepSeconds
            }
            catch {
                Write-Warning "Failed to download $url : $_"
            }
        }
        
        # Conflict Cleanup (Generic vs Date-Prefixed)
        # If we just made 2025-10-foo.jpg, delete foo.jpg
        $genericPath = Join-Path $imagesDir $cleanName
        if ((Test-Path $genericPath) -and ($genericPath -ne $localPath)) {
            Write-Host "   Deleting conflict: $cleanName"
            Remove-Item $genericPath -Force
        }
    }
}

# 5. Regenerate Markdown Files
Write-Host "Regenerating Markdown files..."

$xmlItems = $xmlDoc.SelectNodes("//item")
# Create ID->URL map for Cover Images
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
        # Metadata
        $title = Fix-Encoding-Simple $item.SelectSingleNode("title").InnerText
        $date = $item.SelectSingleNode("wp:post_date", $ns).InnerText
        $slug = $item.SelectSingleNode("wp:post_name", $ns).InnerText
        $contentHtml = $item.SelectSingleNode("content:encoded", $ns).InnerText
        
        $dateObj = [datetime]::Parse($date)
        $dateStr = $dateObj.ToString("yyyy-MM-dd")
        if (-not $slug) { $slug = "$pt-$($dateObj.Ticks)" }
        
        $filename = if ($pt -eq "post") { "$dateStr-$slug.md" } else { "$slug.md" }
        $targetPath = if ($pt -eq "post") { Join-Path $postsDir $filename } else { Join-Path $pagesDir $filename }
        
        # Cover Image
        $coverImage = $null
        $thumbIdNode = $item.SelectSingleNode("wp:postmeta[wp:meta_key='_thumbnail_id']/wp:meta_value", $ns)
        if ($thumbIdNode) {
            $tid = $thumbIdNode.InnerText
            if ($attIdToUrl.ContainsKey($tid)) {
                $cUrl = $attIdToUrl[$tid]
                # Check our map of downloaded/processed files
                if ($state.DownloadedMap.ContainsKey($cUrl)) {
                    $coverImage = "/tmm7f/assets/images/" + $state.DownloadedMap[$cUrl]
                }
            }
        }
        
        # Content
        $contentMd = Convert-HtmlToMarkdown $contentHtml
        $contentMd = Fix-Encoding-Simple $contentMd
        
        # Link Replacement in MD
        $contentMd = [Regex]::Replace($contentMd, '\((https?://[^)]+)\)', {
                param($m)
                $foundUrl = $m.Groups[1].Value
                # Try Exact
                if ($state.DownloadedMap.ContainsKey($foundUrl)) {
                    return "(/tmm7f/assets/images/" + $state.DownloadedMap[$foundUrl] + ")"
                }
                # Try Clean
                $cleanFound = $foundUrl -replace "\?.*$", ""
                if ($state.DownloadedMap.ContainsKey($cleanFound)) {
                    return "(/tmm7f/assets/images/" + $state.DownloadedMap[$cleanFound] + ")"
                }
                return "($foundUrl)"
            })
        
        $contentMd = [Regex]::Replace($contentMd, '!\[\]\((https?://[^)]+)\)', {
                param($m)
                $foundUrl = $m.Groups[1].Value
                # Try Exact
                if ($state.DownloadedMap.ContainsKey($foundUrl)) {
                    return "![](/tmm7f/assets/images/" + $state.DownloadedMap[$foundUrl] + ")"
                }
                # Try Clean
                $cleanFound = $foundUrl -replace "\?.*$", ""
                if ($state.DownloadedMap.ContainsKey($cleanFound)) {
                    return "![](/tmm7f/assets/images/" + $state.DownloadedMap[$cleanFound] + ")"
                }
                return "![]($foundUrl)"
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
        if ($coverImage) { [void]$sb.AppendLine("image: `"$coverImage`"") }
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine($contentMd)
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($targetPath, $sb.ToString(), $utf8NoBom)
    }
}

# 6. Update State
$state.LastIndex = $endIndex + 1
$state | ConvertTo-Json -Depth 10 | Set-Content $stateFile

# 7. Git Push
Write-Host "Git Push..."
git add assets/images _posts pages
git commit -m "Batch download images ($startIndex-$endIndex)"
git push

Write-Host "Batch Complete! Next start index: $($state.LastIndex)"
