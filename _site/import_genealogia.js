const fs = require('fs');
const path = require('path');
const xlsx = require('xlsx');

const excelFile = 'arvore ubirajara excel.xlsx';
const outputDir = path.join(__dirname, '_genealogia');

// Create directory if not exists
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
}

try {
    const wb = xlsx.readFile(excelFile);
    const ws = wb.Sheets[wb.SheetNames[0]];
    const rawData = xlsx.utils.sheet_to_json(ws, { header: 1 });

    // Ignore the first row as it has bad headers
    // Loop right from row 1 since row 0 is headers
    let imported = 0;

    for (let i = 1; i < rawData.length; i++) {
        const row = rawData[i];

        // Skip empty rows
        if (!row || row.length === 0 || (!row[0] && !row[2])) {
            continue;
        }

        // Map according to indices
        const codigo_pai = row[0] ? String(row[0]).trim() : '';
        const codigo_final = row[2] ? String(row[2]).trim() : '';
        const nome_do_centro = row[3] ? String(row[3]).trim() : '';
        const terreiro_pai = row[4] ? String(row[4]).trim() : '';
        const ano_fundacao = row[5] ? row[5] : '';
        let encerramento = row[6] ? String(row[6]).trim() : '';
        if (!encerramento && row[14]) encerramento = String(row[14]).trim();
        const pais = row[7] ? String(row[7]).trim() : '';
        const estado = row[8] ? String(row[8]).trim() : '';
        const cidade = row[9] ? String(row[9]).trim() : '';
        const dirigente_material_fundador = row[10] ? String(row[10]).trim() : '';
        const dirigente_espiritual_fundador = row[11] ? String(row[11]).trim() : '';
        const sucessores_espirituais = row[12] ? String(row[12]).trim() : '';
        const sucessores_materiais = row[13] ? String(row[13]).trim() : '';
        const endereco_original = row[15] ? String(row[15]).trim() : '';
        const endereco_atual = row[16] ? String(row[16]).trim() : '';
        const dados_de_contato = row[17] ? String(row[17]).trim() : '';

        // If no codigo_final, we can't create a good filename
        if (!codigo_final && !codigo_pai) continue;

        const safeFilename = codigo_final ? codigo_final.replace(/[^a-zA-Z0-9.\-]/g, '') : `unknown_${i}`;

        let frontMatter = `---\n`;
        frontMatter += `codigo_pai: "${codigo_pai}"\n`;
        frontMatter += `codigo_final: "${codigo_final}"\n`;
        frontMatter += `nome_do_centro: ${JSON.stringify(nome_do_centro)}\n`;
        frontMatter += `terreiro_pai: ${JSON.stringify(terreiro_pai)}\n`;
        frontMatter += `ano_fundacao: ${ano_fundacao ? ano_fundacao : '""'}\n`;
        frontMatter += `encerramento: "${encerramento}"\n`;
        frontMatter += `pais: "${pais}"\n`;
        frontMatter += `estado: "${estado}"\n`;
        frontMatter += `cidade: "${cidade}"\n`;
        frontMatter += `dirigente_material_fundador: ${JSON.stringify(dirigente_material_fundador)}\n`;
        frontMatter += `dirigente_espiritual_fundador: ${JSON.stringify(dirigente_espiritual_fundador)}\n`;
        frontMatter += `sucessores_espirituais: ${JSON.stringify(sucessores_espirituais)}\n`;
        frontMatter += `sucessores_materiais: ${JSON.stringify(sucessores_materiais)}\n`;
        frontMatter += `endereco_original: ${JSON.stringify(endereco_original)}\n`;
        frontMatter += `endereco_atual: ${JSON.stringify(endereco_atual)}\n`;
        frontMatter += `dados_de_contato: ${JSON.stringify(dados_de_contato)}\n`;
        frontMatter += `---\n`;

        const filepath = path.join(outputDir, `${safeFilename}.md`);
        fs.writeFileSync(filepath, frontMatter, 'utf8');
        imported++;
    }

    console.log(`Successfully imported ${imported} records into _genealogia/`);
} catch (e) {
    console.error('Error reading excel or writing files:', e);
}
