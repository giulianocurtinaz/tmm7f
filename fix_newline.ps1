
$pontosDir = ".\_pontos"

$files = Get-ChildItem -Path $pontosDir -Recurse -Include *.md, *.html

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check for the specific corruption: category: "Desc"title:
    if ($content -match 'category:\s*".*?"title:') {
        # Insert newline before title:
        $content = $content -replace '(category:\s*".*?")(title:)', "$1`r`n$2"
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Fixed newline in $($file.Name)"
    }
}
