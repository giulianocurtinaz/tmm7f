$ErrorActionPreference = "Stop"
$baseDir = Get-Location
$xmlPath = Join-Path $baseDir "meusite.xml"
$postsDir = Join-Path $baseDir "_posts"
$pagesDir = Join-Path $baseDir "pages"

# 0. Load XML
Write-Host "Loading XML..."
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load($xmlPath)

$ns = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$ns.AddNamespace("wp", "http://wordpress.org/export/1.2/")
$ns.AddNamespace("content", "http://purl.org/rss/1.0/modules/content/")

$items = $xmlDoc.SelectNodes("//item")

# 1. Clean Dirs
if (Test-Path $postsDir) { Remove-Item (Join-Path $postsDir "*.md") -Force -ErrorAction SilentlyContinue }
else { New-Item -Path $postsDir -ItemType Directory | Out-Null }
if (Test-Path $pagesDir) { Remove-Item (Join-Path $pagesDir "*.md") -Force -ErrorAction SilentlyContinue }
else { New-Item -Path $pagesDir -ItemType Directory | Out-Null }

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
    
    # Use Char codes to avoid script encoding issues
    # Ã (C3) + char
    $C3 = [char]0xC3
    
    $out = $text -replace "$C3$([char]0xA9)", "é"
    $out = $out -replace "$C3$([char]0xA3)", "ã"
    $out = $out -replace "$C3$([char]0xA1)", "á"
    $out = $out -replace "$C3$([char]0xA2)", "â"
    $out = $out -replace "$C3$([char]0xAA)", "ê"
    $out = $out -replace "$C3$([char]0xB3)", "ó"
    $out = $out -replace "$C3$([char]0xB4)", "ô"
    $out = $out -replace "$C3$([char]0xB5)", "õ"
    $out = $out -replace "$C3$([char]0xBA)", "ú"
    $out = $out -replace "$C3$([char]0xA7)", "ç"
    $out = $out -replace "$C3$([char]0x20)", "à"
    $out = $out -replace "$C3$([char]0xAD)", "í"

    # Weird XML Artifacts:    # Specific XML artifacts observed - utilizing String.Replace for literal matching
    $out = $out.Replace([string][char]0x01DC, "ã")
    $out = $out.Replace([string][char]0x01ED, "á")
    $out = $out.Replace([string][char]0x01F8, "é")
    $out = $out.Replace([string][char]0xFFFD, "ç") # Replacement char -> ç
    
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

# 3. Build Map
Write-Host "Building Map..."
$attachmentMap = @{}
foreach ($item in $items) {
    $pt = $item.SelectSingleNode("wp:post_type", $ns).InnerText
    if ($pt -eq "attachment") {
        $id = $item.SelectSingleNode("wp:post_id", $ns).InnerText
        $url = $item.SelectSingleNode("wp:attachment_url", $ns).InnerText
        if (-not $url) { $url = $item.SelectSingleNode("guid").InnerText }
        if ($url) {
            $fname = [System.IO.Path]::GetFileName($url)
            $norm = Get-NormalizedName $fname
            $attachmentMap[$id] = "/assets/images/$norm"
        }
    }
}

# 4. Process Items
Write-Host "Processing Items..."
foreach ($item in $items) {
    $pt = $item.SelectSingleNode("wp:post_type", $ns).InnerText
    if ($pt -eq "post" -or $pt -eq "page") {
        $title = Fix-Encoding $item.SelectSingleNode("title").InnerText
        $date = $item.SelectSingleNode("wp:post_date", $ns).InnerText
        $slug = $item.SelectSingleNode("wp:post_name", $ns).InnerText
        $contentHtml = $item.SelectSingleNode("content:encoded", $ns).InnerText
        
        $dateObj = [datetime]::Parse($date)
        $dateStr = $dateObj.ToString("yyyy-MM-dd")
        
        if ($pt -eq "post") {
            if (-not $slug) { $slug = "post-$($dateObj.Ticks)" }
            $filename = "$dateStr-$slug.md"
            $targetPath = Join-Path $postsDir $filename
            $layout = "post"
        }
        else {
            if (-not $slug) { $slug = "page-$($dateObj.Ticks)" }
            $filename = "$slug.md"
            $targetPath = Join-Path $pagesDir $filename
            $layout = "page"
        }
        
        $cats = @()
        $categoryNodes = $item.SelectNodes("category[@domain='category']")
        foreach ($c in $categoryNodes) { if ($c.InnerText -ne "Sem categoria") { $cats += $c.InnerText } }
        
        $coverImage = $null
        $thumbIdNode = $item.SelectSingleNode("wp:postmeta[wp:meta_key='_thumbnail_id']/wp:meta_value", $ns)
        if ($thumbIdNode) {
            $tid = $thumbIdNode.InnerText
            if ($attachmentMap.ContainsKey($tid)) { $coverImage = $attachmentMap[$tid] }
        }
        
        $contentMd = Convert-HtmlToMarkdown $contentHtml
        $contentMd = Fix-Encoding $contentMd
        
        $contentMd = [Regex]::Replace($contentMd, '\((https?://[^)]+)\)', {
                param($m)
                $url = $m.Groups[1].Value
                $fn = [System.IO.Path]::GetFileName($url)
                if ($url -match "\.(jpg|jpeg|png|gif|webp)(\?.*)?$" -or $url -match "uploads") {
                    if ($fn -match "(.+?)\?") { $fn = $matches[1] }
                    $norm = Get-NormalizedName $fn
                    return "(/assets/images/$norm)"
                }
                return "($url)"
            })
        
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine("layout: $layout")
        [void]$sb.AppendLine("title: `"$title`"")
        [void]$sb.AppendLine("date: $dateStr")
        if ($cats.Count -gt 0) {
            [void]$sb.AppendLine("categories:")
            foreach ($c in $cats) { [void]$sb.AppendLine("  - `"$c`"") }
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
