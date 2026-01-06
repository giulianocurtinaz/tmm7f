const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

const SOURCE_HTML = 'pontos_estruturados_fiel.html';
const AUDIO_DIR = path.join('assets', 'audio');

function main() {
    if (!fs.existsSync(SOURCE_HTML)) {
        console.error('Source HTML not found!');
        return;
    }

    const html = fs.readFileSync(SOURCE_HTML, 'utf-8');
    const $ = cheerio.load(html);
    const audioCounts = {};
    const missing = [];

    const existingFiles = new Set(fs.readdirSync(AUDIO_DIR).map(f => f.toLowerCase()));

    $('article.ponto-cantado').each((i, el) => {
        const id = $(el).attr('id').replace('ponto-', '');

        $(el).find('audio').each((j, audio) => {
            const originalSrc = $(audio).attr('src');
            if (!originalSrc) return;

            if (!audioCounts[id]) audioCounts[id] = 0;
            audioCounts[id]++;
            const version = audioCounts[id];

            // Construct expected filename(s) to check
            // We don't know the exact extension if it wasn't downloaded, 
            // but we can guess it matches the source or is .ogg/.mp3
            // The previous script used the extension from the source URL.

            const urlExt = path.extname(new URL(originalSrc, 'http://example.com').pathname); // Handle relative URLs if any
            const expectedName = `ponto-${id}-v${version}${urlExt}`.toLowerCase();

            // Check if *any* file with this base name exists (ignoring extension mismatch for checking existence)
            // Actually, let's check strict first.
            let found = false;

            // Check specific file first
            if (existingFiles.has(expectedName)) {
                found = true;
            } else {
                // Check if any extension exists for this ID+Version
                const base = `ponto-${id}-v${version}`;
                for (const f of existingFiles) {
                    if (f.startsWith(base)) {
                        found = true;
                        break;
                    }
                }
            }

            if (!found) {
                missing.push({
                    id: id,
                    version: version,
                    originalUrl: originalSrc
                });
            }
        });
    });

    console.log(JSON.stringify(missing, null, 2));
    console.log(`\nTotal Missing: ${missing.length}`);
}

main();
