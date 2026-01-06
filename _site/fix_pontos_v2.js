const fs = require('fs');
const path = require('path');
const dir = '_pontos';

fs.readdirSync(dir).forEach(file => {
    if (!file.endsWith('.md')) return;
    const fullPath = path.join(dir, file);
    let content = fs.readFileSync(fullPath, 'utf8');

    // Normalize line endings and tabs
    content = content.replace(/\r\n/g, '\n').replace(/\t/g, '  ');

    const parts = content.split('---');
    if (parts.length < 3) {
        console.log(`Skipping ${file} (bad structure)`);
        return;
    }

    let frontMatter = parts[1];
    let body = parts.slice(2).join('---');

    let newFM = "";
    const lines = frontMatter.split('\n');

    lines.forEach(line => {
        // Skip empty lines in FM or just preserve them? Preserving for now.
        // But trimming empty lines at start/end of FM is good.
        if (!line.trim()) {
            newFM += line + '\n';
            return;
        }
        // Matches key: value
        // Note: List items "- url: ..." won't match keys starting with "-" using this regex, 
        // but might match if I use [\w-] and check logic.
        // My regex: ^(\s*)([\w_]+):\s*(.*)$
        // This matches "title: ...", "  caption: ..."
        // Does NOT match "- url: ..." because "- " is not \s*[\w_]
        const match = line.match(/^(\s*)([\w_]+):\s*(.*)$/);
        if (match) {
            const indent = match[1];
            const key = match[2];
            let val = match[3];

            if (['title', 'category', 'id_ponto', 'caption'].includes(key) || key === 'layout') {
                // Strip existing outer quotes if present to avoid double wrapping
                let cleanVal = val.trim();
                if (cleanVal.length >= 2) {
                    if (cleanVal.startsWith('"') && cleanVal.endsWith('"')) {
                        cleanVal = cleanVal.substring(1, cleanVal.length - 1);
                    }
                    else if (cleanVal.startsWith("'") && cleanVal.endsWith("'")) {
                        cleanVal = cleanVal.substring(1, cleanVal.length - 1);
                    }
                }

                // Sanitize inner double quotes to single
                cleanVal = cleanVal.replace(/"/g, "'");

                // Re-wrap in double quotes
                newFM += `${indent}${key}: "${cleanVal}"\n`;
            } else {
                // Other keys (e.g. audios, or unknown) -> keep as is
                newFM += line + '\n';
            }
        } else {
            // List items or comments
            newFM += line + '\n';
        }
    });

    const newContent = `---${newFM}---${body}`;
    if (newContent !== content) {
        fs.writeFileSync(fullPath, newContent);
        console.log(`Fixed ${file}`);
    }
});
