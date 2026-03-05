const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');

const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
let count = 0;
files.forEach(file => {
    const filePath = path.join(dir, file);
    const buf = fs.readFileSync(filePath);
    
    // Check for UTF-8 BOM EF BB BF
    if (buf.length >= 3 && buf[0] === 0xEF && buf[1] === 0xBB && buf[2] === 0xBF) {
        // Slice off the 3 bytes
        const noBom = buf.slice(3);
        fs.writeFileSync(filePath, noBom);
        count++;
        console.log('Stripped BOM from:', file);
    }
});
console.log('Stripped BOM from ' + count + ' files.');
