# Normalização de Categorias - Remoção de Acentos
# Autor: Antigravity
# Data: 2026-01-07

$sourceDir = ".\_pontos"
$files = Get-ChildItem -Path $sourceDir -Filter "*.md"
$count = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content

    # Substituições (Regex para garantir que estamos alterando apenas o valor do campo category)
    # Procura por 'category: "Valor"' ou 'category: Valor'
    
    # Oxalá -> Oxala
    $content = $content -replace 'category:\s*"?Oxalá"?', 'category: "Oxala"'
    # Iemanjá -> Iemanja
    $content = $content -replace 'category:\s*"?Iemanjá"?', 'category: "Iemanja"'
    # Oxóssi -> Oxossi
    $content = $content -replace 'category:\s*"?Oxóssi"?', 'category: "Oxossi"'
    # Xangô -> Xango
    $content = $content -replace 'category:\s*"?Xangô"?', 'category: "Xango"'
    # Iansã -> Iansa
    $content = $content -replace 'category:\s*"?Iansã"?', 'category: "Iansa"'
    # Específicos -> Especificos
    $content = $content -replace 'category:\s*"?Específicos"?', 'category: "Especificos"'

    if ($content -ne $originalContent) {
        $content | Set-Content -Path $file.FullName -Encoding UTF8
        Write-Host "Atualizado: $($file.Name)"
        $count++
    }
}

Write-Host "Total de arquivos atualizados: $count"
