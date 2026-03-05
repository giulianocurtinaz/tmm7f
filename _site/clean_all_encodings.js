const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, '_genealogia');

const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
files.forEach(file => {
    const filePath = path.join(dir, file);
    const buf = fs.readFileSync(filePath);
    
    // Check for UTF-16 LE/BE BOM
    if (buf.length >= 2 && ((buf[0] === 0xFF && buf[1] === 0xFE) || (buf[0] === 0xFE && buf[1] === 0xFF))) {
        // Read as UTF-16 and convert to UTF-8
        let str = buf.toString('utf16le');
        fs.writeFileSync(filePath, str, 'utf8');
        console.log('Converted UTF-16 to UTF-8:', file);
    } else {
        // Read as string and rewrite to clean any weird string-start bytes
        let str = buf.toString('utf8');
        // Remove zero width no-break space / BOM if it was parsed as string
        str = str.replace(/^\uFEFF/, '');
        // Replace CRLF with LF to be super safe for Jekyll
        str = str.replace(/\r\n/g, '\n');
        fs.writeFileSync(filePath, str, 'utf8');
        // console.log('Rewrote UTF-8:', file);
    }
});
