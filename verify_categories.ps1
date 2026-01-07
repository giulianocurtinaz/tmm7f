
$pontosDir = ".\_pontos"
$allowedCategories = @("Hinos", "Oxalá", "Iemanjá", "Oxum", "Oxóssi", "Xangô", "Iansã", "Ogum", "Cosme", "Pretos Velhos", "Oriente", "Específicos", "Hino")

$files = Get-ChildItem -Path $pontosDir -Recurse -Include *.md, *.html
$invalidFiles = @()

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    if ($content -match 'category:\s*"?([^"\r\n]+)"?') {
        $category = $matches[1].Trim()
        if ($allowedCategories -notcontains $category) {
            $invalidFiles += [PSCustomObject]@{
                File     = $file.Name
                Category = $category
            }
        }
    }
    else {
        $invalidFiles += [PSCustomObject]@{
            File     = $file.Name
            Category = "MISSING"
        }
    }
}

if ($invalidFiles.Count -eq 0) {
    Write-Host "SUCCESS: All files have valid categories."
}
else {
    Write-Warning "Found $($invalidFiles.Count) files with invalid categories:"
    $invalidFiles | Format-Table -AutoSize
}
