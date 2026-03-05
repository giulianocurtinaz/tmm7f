const fs = require('fs');
const xlsx = require('xlsx');

try {
    const wb = xlsx.readFile('arvore ubirajara excel.xlsx');
    const ws = wb.Sheets[wb.SheetNames[0]];
    const data = xlsx.utils.sheet_to_json(ws, { header: 1 });

    console.log('Top 5 rows:');
    for (let i = 0; i < Math.min(5, data.length); i++) {
        console.log(`Row ${i}:`, JSON.stringify(data[i]));
    }
} catch (e) {
    console.error('Error reading excel:', e);
}
