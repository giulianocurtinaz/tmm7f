const fs = require('fs');
const path = require('path');
const dir = '_pontos';

fs.readdirSync(dir).forEach(file => {
    if (!file.endsWith('.md')) return;
    const fullPath = path.join(dir, file);
    let content = fs.readFileSync(fullPath, 'utf8');

    let modified = false;

    // Fix Title: title: "..."
    content = content.replace(/^title: "(.*)"$/m, (match, p1) => {
        if (p1.includes('"')) {
            console.log(`Fixing title in ${file}: ${p1}`);
            const fixed = p1.replace(/"/g, "'");
            modified = true;
            return `title: "${fixed}"`;
        }
        return match;
    });

    // Fix Caption: caption: "..."
    content = content.replace(/^(\s*)caption: "(.*)"$/gm, (match, indent, p1) => {
        if (p1.includes('"')) {
            console.log(`Fixing caption in ${file}: ${p1}`);
            const fixed = p1.replace(/"/g, "'");
            modified = true;
            return `${indent}caption: "${fixed}"`;
        }
        return match;
    });

    if (modified) {
        fs.writeFileSync(fullPath, content);
    }
});
