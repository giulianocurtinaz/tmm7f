
$pontosDir = ".\_pontos"

# Define ranges and their categories (Inclusive ranges)
$mapBase = @(
    @("001", "007", "Hinos"),
    @("008", "018", "Oxalá"),
    @("019", "061", "Iemanjá"),
    @("062", "069", "Oxum"),
    @("070", "137", "Oxóssi"),
    @("138", "177", "Xangô"),
    @("178", "185", "Iansã"),
    @("186", "255", "Ogum"),
    @("256", "274", "Cosme"),
    @("275", "284", "Oriente"),
    @("285", "360", "Pretos Velhos"),
    @("361", "372", "Específicos"),
    @("373", "374", "Hino"),
    @("375", "393", "Específicos"),
    @("394", "394", "Hino"),
    @("395", "400", "Específicos"),
    @("401", "402", "Hino")
)

# Convert map to a more usable dictionary for ranges
function Get-CategoryForID {
    param([int]$id)
    
    foreach ($entry in $mapBase) {
        $start = [int]$entry[0]
        $end = [int]$entry[1]
        if ($id -ge $start -and $id -le $end) {
            return $entry[2]
        }
    }
    return $null
}

# Process Files
$files = Get-ChildItem -Path $pontosDir -Recurse -Include *.md, *.html

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check for frontmatter
    if ($content -match '(?ms)^---\s*(.*?)\s*---') {
        $yaml = $matches[1]
        
        # Extract ID
        $idStr = ""
        if ($yaml -match 'id_ponto:\s*"?(\d+)"?') {
            $idStr = $matches[1]
        }
        elseif ($yaml -match 'id:\s*"?(\d+)"?') {
            $idStr = $matches[1]
        }
        
        if ($idStr -ne "") {
            $idInt = [int]$idStr
            $newCategory = Get-CategoryForID -id $idInt
            
            if ($newCategory) {
                # Format ID to 3 digits
                $newIdFormatted = "{0:D3}" -f $idInt
                
                # Replace logic
                # 1. Update/Inject ID (ensuring id_ponto)
                # 2. Update Category
                
                # Reconstruct YAML carefully or Regex Replace
                
                # Replace ID (normalize to id_ponto)
                if ($content -match 'id_ponto:\s*"?\d+"?') {
                    $content = $content -replace 'id_ponto:\s*"?\d+"?', "id_ponto: `"$newIdFormatted`""
                }
                elseif ($content -match 'id:\s*"?\d+"?') {
                    $content = $content -replace 'id:\s*"?\d+"?', "id_ponto: `"$newIdFormatted`""
                }
                
                # Replace Category
                if ($content -match 'category:\s*"?.*?"?(\r?\n)') {
                    $content = $content -replace 'category:\s*"?.*?"?(\r?\n)', "category: `"$newCategory`"$1"
                }
                else {
                    # If category is missing, append it after ordenacao or id_ponto
                    $content = $content -replace '(id_ponto: ".*?")', "$1`r`ncategory: `"$newCategory`""
                }
                
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8
                Write-Host "Updated $($file.Name): ID $newIdFormatted -> $newCategory"
            }
            else {
                Write-Warning "No category mapping found for ID $idStr in $($file.Name)"
            }
        }
        else {
            Write-Warning "Could not find ID in $($file.Name)"
        }
    }
}
