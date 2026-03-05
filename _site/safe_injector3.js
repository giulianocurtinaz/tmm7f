const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));

files.forEach(file => {
    const filePath = path.join(dir, file);
    let content = fs.readFileSync(filePath, 'utf8');
    
    const nameMatch = content.match(/nome_do_centro:\s*(.+)/);
    if (!nameMatch) return;
    
    let rawName = nameMatch[1].trim().replace(/^['"]|['"]$/g, '');
    let words = rawName.split(/\s+/);
    let shortName = words.length >= 2 ? words.slice(-2).join(' ') : rawName;
    
    if (content.includes('nome_simplificado:')) {
        content = content.replace(/nome_simplificado:\s*.*/, "nome_simplificado: '" + shortName + "'");
    } else {
        content = content.replace(/(nome_do_centro:.*(\r?\n))/, "\$1nome_simplificado: '" + shortName + "'\n");
    }
    
    fs.writeFileSync(filePath, Buffer.from(content, 'utf8'));
});
console.log('Done injecting using literal heredoc.');
