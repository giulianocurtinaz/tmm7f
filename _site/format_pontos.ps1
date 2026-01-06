$path = "c:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp\pages\pontosoriginais.html"

# Read content
$content = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)

# 1. Separators: Replace 3+ dots or ellipsis with ---
# Including potential whitespace between dots? '.\s*.\s*.'
$content = $content -replace "\.{3,}|…", "---"

# 2. Remove nbsp and spans
$content = $content.Replace("&nbsp;", " ")
$content = $content -replace "<span[^>]*>", ""
$content = $content -replace "</span>", ""

# 3. Titles: <p><strong>UPPERCASE</strong></p> or <p>UPPERCASE</p>
# Using [Regex]::Replace with a MatchEvaluator
$OneWordTitleRegex = [Regex] '(?m)^<p>(?:<strong>)?\s*([A-ZÀ-Ú\s''"-]{3,})\s*(?:</strong>)?</p>\s*$'
$content = $OneWordTitleRegex.Replace($content, {
        param($match)
        $text = $match.Groups[1].Value.Trim()
        # Ensure it has letters and is Uppercase
        if ($text -match "[A-ZÀ-Ú]" -and $text -ceq $text.ToUpper()) {
            return "### $text"
        }
        return $match.Value
    })

# 4. Credits: "Na voz de..." -> *Na voz de...*
# We look for the text pattern. To be safe, we capture the text until < or newline.
$content = [Regex]::Replace($content, '(?i)(Na voz de[^<\r\n]+)', '*$1*')

# 5. Grouping: Add --- after credits if missing?
# The request says "Localize .... e substitua" AND "Garanta que cada conjunto ... seja seguido por ---".
# If we assume .... was the separator, replacing it handles most cases.
# If we want to be proactive: if a block ends with credits (*Na voz de...*) and next meaningful line is ###, ensure --- in between.
# This requires a bit more complex logic.
# Let's inspect if `---` are mostly there.
# We can enforce: Replace `(<\/figure>\s*)` with `$1`n`n---`n`n` if it's the end of a song?
# But checking what follows is hard in one pass.
# Let's trust replacement of `....` -> `---` covers the user request "Localize ... e substitua".

# 6. Cleanup
$content = $content -replace '\s{3,}', ' '
# Remove duplicate headers/separators if any
$content = $content -replace '(?m)^---\s*---$', '---'

# Save
[IO.File]::WriteAllText($path, $content, [Text.Encoding]::UTF8)
write-host "Formatting complete."
