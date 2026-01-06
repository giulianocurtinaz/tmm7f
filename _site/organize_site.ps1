$ErrorActionPreference = "Stop"

$baseDir = Get-Location
$pagesImagesDir = Join-Path $baseDir "pages\images"
$assetsImagesDir = Join-Path $baseDir "assets\images"
$postsDir = Join-Path $baseDir "_posts"
$pagesDir = Join-Path $baseDir "pages"

$sitePrefix = "/tmm7f"

function Remove-Diacritics {
    param ([string]$text)
    $normalized = $text.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    return $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
}

function Normalize-Filename {
    param ([string]$filename)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    $ext = [System.IO.Path]::GetExtension($filename)
    
    $name = Remove-Diacritics $name
    $name = $name.ToLower() -replace ' ', '-'
    $name = $name -replace '[^a-z0-9\-]', ''
    
    return "$name$($ext.ToLower())"
}

Write-Host "--- Migrating Images ---"
if (Test-Path $pagesImagesDir) {
    if (-not (Test-Path $assetsImagesDir)) {
        New-Item -ItemType Directory -Force -Path $assetsImagesDir | Out-Null
    }

    $files = Get-ChildItem -Path $pagesImagesDir -File
    foreach ($file in $files) {
        $newName = Normalize-Filename $file.Name
        $destPath = Join-Path $assetsImagesDir $newName
        
        if (-not (Test-Path $destPath)) {
            Move-Item -Path $file.FullName -Destination $destPath
            Write-Host "Moved: $($file.Name) -> $newName"
        } else {
            Write-Host "Skipped (Exists): $($file.Name) -> $newName"
        }
    }
} else {
    Write-Host "Directory not found: $pagesImagesDir"
}

Write-Host "`n--- Updating Markdown Files ---"

$mdFiles = @()
if (Test-Path $postsDir) { $mdFiles += Get-ChildItem -Path $postsDir -Filter *.md -Recurse }
if (Test-Path $pagesDir) { $mdFiles += Get-ChildItem -Path $pagesDir -Filter *.md -Recurse }

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # 1. Update Image Links: (images/Something.jpg) -> (/tmm7f/assets/images/something.jpg)
    $content = [Regex]::Replace($content, '\(images/([^)]+)\)', {
        param($match)
        $imgName = $match.Groups[1].Value
        $newImgName = Normalize-Filename $imgName
        return "($sitePrefix/assets/images/$newImgName)"
    })
    
    # 2. Update Front Matter (Pages only)
    if ($file.DirectoryName -eq $pagesDir -or $file.DirectoryName.StartsWith($pagesDir)) {
         # Ensure layout: page
        if ($content -notmatch 'layout: page') {
             if ($content -match '^---\s*(\r?\n)') {
                 $content = $content -replace '^---\s*(\r?\n)', "---\nlayout: page`n"
             }
        }
        
        # Checking coverImage
        $content = [Regex]::Replace($content, 'coverImage:\s*["'']?([^"''\r\n]+)["'']?', {
            param($match)
            $imgName = $match.Groups[1].Value
            if ($imgName -match '^http' -or $imgName -match '^/') {
                return $match.Value
            }
            $newImgName = Normalize-Filename $imgName
            return "coverImage: `"$sitePrefix/assets/images/$newImgName`""
        })
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Updated: $($file.Name)"
    }
}

Write-Host "`n--- Done ---"
