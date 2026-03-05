$pontosDir = ".\_pontos"
$files = Get-ChildItem -Path $pontosDir -Filter "*.md"

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Extract ID
    if ($content -match 'id_ponto:\s*"(\d+)"') {
        $id = [int]$matches[1]
        $newCategory = ""

        # Determine Category based on ID range
        if ($id -ge 1 -and $id -le 7) { $newCategory = "Hinos" }
        elseif ($id -ge 8 -and $id -le 18) { $newCategory = "Oxala" }
        elseif ($id -ge 19 -and $id -le 61) { $newCategory = "Iemanja" }
        elseif ($id -ge 62 -and $id -le 69) { $newCategory = "Oxum" }
        elseif ($id -ge 70 -and $id -le 137) { $newCategory = "Oxossi" }
        elseif ($id -ge 138 -and $id -le 177) { $newCategory = "Xango" }
        elseif ($id -ge 178 -and $id -le 185) { $newCategory = "Iansa" }
        elseif ($id -ge 186 -and $id -le 255) { $newCategory = "Ogum" }
        elseif ($id -ge 256 -and $id -le 274) { $newCategory = "Cosme" }
        elseif ($id -ge 275 -and $id -le 284) { $newCategory = "Oriente" }
        elseif ($id -ge 285 -and $id -le 360) { $newCategory = "Pretos" }
        elseif ($id -ge 361 -and $id -le 402) { $newCategory = "Outros" }

        if ($newCategory -ne "") {
            # Regex replace to update category safely
            # We look for 'category: "OldValue"' or 'category: OldValue'
            # We replace it ensuring the structure remains
            
            $newContent = $content -replace '(?m)^category:.*$', "category: `"$newCategory`""
            
            if ($content -ne $newContent) {
                Set-Content -Path $file.FullName -Value $newContent -NoNewline
                Write-Host "Updated $($file.Name): ID $id -> $newCategory"
            }
        }
    }
    else {
        Write-Warning "Could not find id_ponto in $($file.Name)"
    }
}
Write-Host "Update completed."
