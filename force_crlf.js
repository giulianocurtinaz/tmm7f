const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');

const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));

files.forEach(file => {
    const filePath = path.join(dir, file);
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Convert all \r\n and \n to pure \n first to normalize
    content = content.replace(/\r\n/g, '\n');
    
    // Now convert all \n to \r\n since Windows Ruby strictly demands it for YAML here
    content = content.replace(/\n/g, '\r\n');
    
    fs.writeFileSync(filePath, Buffer.from(content, 'utf8'));
});
console.log('Forced CRLF line endings on all markdown files.');
