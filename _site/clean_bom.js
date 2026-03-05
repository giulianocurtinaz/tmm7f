const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');

fs.readdirSync(dir).forEach(file => {
    if(!file.endsWith('.md')) return;
    const filePath = path.join(dir, file);
    
    // Read clean UTF-8 (ignores BOM if present, but readFileSync handles it)
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Strip BOM if it accidentally got read
    if (content.charCodeAt(0) === 0xFEFF) {
        content = content.slice(1);
    }
    
    // Write back clean UTF-8 without BOM
    fs.writeFileSync(filePath, content, 'utf8');
});
console.log('Node.js UTF-8 BOM cleanup complete.');
