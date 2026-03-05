const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');

const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));

files.forEach(file => {
    const filePath = path.join(dir, file);
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Nuke \r completely
    content = content.replace(/\r/g, '');
    
    // Ensure the file exactly starts with ---
    if (!content.startsWith('---')) {
        content = '---\n' + content;
    }
    
    fs.writeFileSync(filePath, Buffer.from(content, 'utf8'));
});
console.log('Forced LF line endings on all markdown files.');
