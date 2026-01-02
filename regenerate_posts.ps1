$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$xmlPath = Join-Path $baseDir "meusite.xml"
$postsDir = Join-Path $baseDir "_posts"
$pagesDir = Join-Path $baseDir "pages"
$stateFile = Join-Path $baseDir "download_state.json"

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

# Load XML
Write-Host "Loading XML..."
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load($xmlPath)
$ns = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$ns.AddNamespace("wp", "http://wordpress.org/export/1.2/")
$ns.AddNamespace("content", "http://purl.org/rss/1.0/modules/content/")

# Load State
Write-Host "Loading State..."
$state = @{ LastIndex = 0; DownloadedMap = @{} }
if (Test-Path $stateFile) {
    try {
        $json = Get-Content $stateFile -Raw | ConvertFrom-Json
        if ($json.DownloadedMap) {
            $json.DownloadedMap.PSObject.Properties | ForEach-Object {
                $state.DownloadedMap[$_.Name] = $_.Value
            }
        }
    }
    catch { Write-Warning "Could not load state." }
}

# Regenerate
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
        
        # Cover Image (Mapping to 'image' for Mediumish)
        $coverImage = $null
        $thumbIdNode = $item.SelectSingleNode("wp:postmeta[wp:meta_key='_thumbnail_id']/wp:meta_value", $ns)
        if ($thumbIdNode) {
            $tid = $thumbIdNode.InnerText
            if ($attIdToUrl.ContainsKey($tid)) {
                $cUrl = $attIdToUrl[$tid]
                # Check map
                if ($state.DownloadedMap.ContainsKey($cUrl)) {
                    $coverImage = "/tmm7f/assets/images/" + $state.DownloadedMap[$cUrl]
                }
            }
        }
        
        # Content
        $contentMd = Convert-HtmlToMarkdown $contentHtml
        $contentMd = Fix-Encoding-Simple $contentMd
        
        # Link Replacement
        $contentMd = [Regex]::Replace($contentMd, '\((https?://[^)]+)\)', {
                param($m)
                $foundUrl = $m.Groups[1].Value
                if ($state.DownloadedMap.ContainsKey($foundUrl)) {
                    return "(/tmm7f/assets/images/" + $state.DownloadedMap[$foundUrl] + ")"
                }
                $cleanFound = $foundUrl -replace "\?.*$", ""
                if ($state.DownloadedMap.ContainsKey($cleanFound)) {
                    return "(/tmm7f/assets/images/" + $state.DownloadedMap[$cleanFound] + ")"
                }
                return "($foundUrl)"
            })
        
         $contentMd = [Regex]::Replace($contentMd, '!\[\]\((https?://[^)]+)\)', {
                param($m)
                $foundUrl = $m.Groups[1].Value
                if ($state.DownloadedMap.ContainsKey($foundUrl)) {
                    return "![](/tmm7f/assets/images/" + $state.DownloadedMap[$foundUrl] + ")"
                }
                $cleanFound = $foundUrl -replace "\?.*$", ""
                if ($state.DownloadedMap.ContainsKey($cleanFound)) {
                    return "![](/tmm7f/assets/images/" + $state.DownloadedMap[$cleanFound] + ")"
                }
                return "![]($foundUrl)"
            })

        # Write
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
        # Mediumish: use 'image'
        if ($coverImage) { [void]$sb.AppendLine("image: `"$coverImage`"") }
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine($contentMd)
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($targetPath, $sb.ToString(), $utf8NoBom)
    }
}
Write-Host "Done."
