const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');

const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));

files.forEach(file => {
    const filePath = path.join(dir, file);
    const content = fs.readFileSync(filePath, 'utf8');
    
    const nameMatch = content.match(/nome_do_centro:\s*(.+)/);
    if (!nameMatch) return;
    
    let rawName = nameMatch[1].trim().replace(/^['"]|['"]$/g, '');
    let words = rawName.split(/\s+/);
    let shortName = words.length >= 2 ? words.slice(-2).join(' ') : rawName;
    
    // Replace carefully without touching any other line
    let newContent = content.replace(/(nome_do_centro:.*(\r?\n))/, "$1nome_simplificado: '" + shortName + "'$2");
    
    fs.writeFileSync(filePath, Buffer.from(newContent, 'utf8'));
});
console.log('Done rewriting files from Git state via Node.js');
