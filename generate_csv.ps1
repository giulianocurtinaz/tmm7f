
$pontosDir = ".\_pontos"
$outputFile = ".\revisao_pontos.csv"

# Function to extract front matter
function Get-FrontMatter {
    param ($path)
    $content = Get-Content -Path $path -Raw -Encoding UTF8
    if ($content -match '(?ms)^---\s*(.*?)\s*---') {
        $yaml = $matches[1]
        $data = @{}
        
        # Simple regex parsing for YAML lines
        if ($yaml -match 'id_ponto:\s*"?(.*?)"?\s*$') { $data['id'] = $matches[1] }
        if ($yaml -match 'category:\s*"?(.*?)"?\s*$') { $data['category'] = $matches[1] }
        if ($yaml -match 'title:\s*"?(.*?)"?\s*$') { $data['title'] = $matches[1] }
        
        return $data
    }
    return $null
}

$results = @()

# Get all files
$files = Get-ChildItem -Path $pontosDir -Recurse -Include *.md, *.html

foreach ($file in $files) {
    try {
        $fm = Get-FrontMatter -path $file.FullName
        if ($fm) {
            # Handle sorting logic (try parse int)
            $sortId = 999999
            if ($fm['id'] -match '^\d+$') {
                $sortId = [int]$fm['id']
            }

            $results += [PSCustomObject]@{
                SortId   = $sortId
                id       = $fm['id']
                category = $fm['category']
                title    = $fm['title']
            }
        }
    }
    catch {
        Write-Warning "Error processing $($file.Name): $_"
    }
}

# Sort and Export
$results | Sort-Object SortId | Select-Object id, category, title | Export-Csv -Path $outputFile -Delimiter ";" -NoTypeInformation -Encoding UTF8

Write-Host "CSV created at $outputFile"
Write-Host "Total records: $($results.Count)"
