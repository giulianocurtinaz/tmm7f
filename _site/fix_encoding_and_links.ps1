$ErrorActionPreference = "Stop"

$directories = @("pages", "_posts")
$baseDir = Get-Location

# Image link pattern to replace
# We want to replace separate instances of "(images/" with "(/assets/images/"
# Note: We escape the parenthesis for regex
$pattern = "\/images\/" 
$replacement = "/assets/images/"

foreach ($dirName in $directories) {
    $dirPath = Join-Path $baseDir $dirName
    if (Test-Path $dirPath) {
        $files = Get-ChildItem -Path $dirPath -Filter "*.md" -Recurse
        
        foreach ($file in $files) {
            Write-Host "Processing $($file.FullName)..."
            
            # Read logic:
            # 1. Try reading as UTF-8 first.
            # 2. If it contains skewed chars or we just want to force a specific re-save.
            # actually PowerShell Get-Content usually handles BOM files correctly.
            # If no BOM, it might default to ANSI.
            # To fix encoding issues, we often rely on Get-Content's auto-handling for reading,
            # but we explicitly save as UTF8.
            
            $content = Get-Content -Path $file.FullName -Raw
            
            # Fix Image Links
            # Replace relative "images/" with absolute assets path
            # Warning: Regex replace. match "(images/" literal.
            # User request: "substituir o texto (images/ por (/assets/images/."
            # We also handle "content/images/" or just "images/" if present?
            # User said specifically: "(images/"
            
            if ($content -match "\(images\/") {
                $content = $content -replace "\(images\/", "(/assets/images/"
                Write-Host "  -> Fixed links."
            }

            # Also check purely "images/" if it's not preceded by assets.
            # But adhering strictly to user request: "(images/" -> "(/assets/images/"
            
            # Save with UTF-8 Encoding
            # PowerShell Core (pwsh) defaults to UTF8 w/o BOM. Windows PowerShell (powershell.exe) might do BOM.
            # Jekyll usually likes UTF-8. 
            # We will use [System.IO.File]::WriteAllText to control this precisely if needed, 
            # or Set-Content -Encoding UTF8 (which usually adds BOM in 5.1). Use UTF8NoBOM if available or .NET.
            # Let's use .NET for cleaner UTF-8 without BOM (standard for web)
            
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
            Write-Host "  -> Saved as UTF-8."
        }
    }
}
Write-Host "Done."
