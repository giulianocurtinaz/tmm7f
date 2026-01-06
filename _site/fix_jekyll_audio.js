const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

const TARGET_MD = 'pontos-cantados.md';
const AUDIO_DIR = path.join('assets', 'audio');

function extractFrontMatter(content) {
    const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
    if (match) {
        return { frontMatter: match[0], body: content.slice(match[0].length) };
    }
    return { frontMatter: '', body: content };
}

function getMimeType(filename) {
    const ext = path.extname(filename).toLowerCase();
    if (ext === '.ogg') return 'audio/ogg';
    if (ext === '.mp3') return 'audio/mpeg';
    if (ext === '.wav') return 'audio/wav';
    return 'audio/mpeg'; // default
}

function main() {
    console.log('Iniciando correção de áudios no Jekyll...');

    if (!fs.existsSync(TARGET_MD)) {
        console.error('Arquivo pontos-cantados.md não encontrado!');
        return;
    }

    const content = fs.readFileSync(TARGET_MD, 'utf-8');
    const { frontMatter, body } = extractFrontMatter(content);

    const $ = cheerio.load(body, {
        decodeEntities: false,
        xmlMode: false // standard html 
    });

    // Get list of actual files for validation (case-insensitive check)
    const realFiles = fs.readdirSync(AUDIO_DIR);
    const fileMap = new Map();
    realFiles.forEach(f => fileMap.set(f.toLowerCase(), f));

    let updatedCount = 0;

    $('audio').each((i, el) => {
        const $el = $(el);
        let src = $el.attr('src');

        if (!src) return;

        // src might be "/assets/audio/..." or "assets/audio/..."
        const basename = path.basename(src);
        const lowerBasename = basename.toLowerCase();

        // 1. Audit / Case Sensitive Fix
        if (fileMap.has(lowerBasename)) {
            const realName = fileMap.get(lowerBasename);
            // Verify extension match
            if (path.extname(realName) !== path.extname(basename)) {
                console.warn(`! Extensão incorreta no HTML: ${basename} (Real: ${realName})`);
            }

            // Update src to use real filename (temporarily standard path)
            // We ensure consistency before Liquid conversion
            $el.attr('src', `/assets/audio/${realName}`);

            // 2. MIME Type
            const mime = getMimeType(realName);
            $el.attr('type', mime);

            updatedCount++;
        } else {
            console.warn(`! Arquivo não encontrado em ${AUDIO_DIR}: ${basename}`);
            // Still try to fix mime if possible, but keep src as is
            const mime = getMimeType(basename);
            $el.attr('type', mime);
        }
    });

    // Get HTML back
    // Cheerio wraps in <html><head><body> usually if loaded that way, but let's see.
    // If we loaded partial, $.html() returns full document usually. 
    // We strictly want the body contents or whatever we passed.
    // `cheerio.load` creates a full DOM. 
    // We should use $('body').html() if we want just the content, 
    // but our content starts with <header> and has no body tag in the file itself usually.
    // Let's use $.html() but check if it adds <html> tags.
    // If input didn't have <html>, cheerio might still add it. 
    // Best way: $('body').html() ??? No, because our input `body` string is just a fragment relative to a page.

    // Actually, `cheerio.load(body)` treats it as a full page.
    // Use `cheerio.load(body, null, false)` for fragment?
    // Let's stick to simple replacement for structure if Cheerio is invasive.
    // Or just extract from `body` if it was wrapped.

    let processedHtml = $.html();

    // Formatting cleanup if Cheerio added html/body tags
    // The original file had <header>... 
    // Cheerio adds <html><head><body>...</body></html>
    // We want content inside <body>

    // Extract content inside body if present
    const bodyMatch = processedHtml.match(/<body>([\s\S]*)<\/body>/);
    if (bodyMatch) {
        processedHtml = bodyMatch[1];
    }

    // 3. Liquid Relative URL Conversion
    // Regex replace: src="/assets/audio/XYZ" -> src="{{ '/assets/audio/XYZ' | relative_url }}"
    // Note: filenames might have dashes or dots.

    const finalHtml = processedHtml.replace(
        /src="\/assets\/audio\/([^"]+)"/g,
        `src="{{ '/assets/audio/$1' | relative_url }}"`
    );

    // Reconstruct
    const finalContent = `${frontMatter}\n${finalHtml}`;

    fs.writeFileSync(TARGET_MD, finalContent, 'utf-8');
    console.log(`\nConcluído! ${updatedCount} tags de áudio processadas.`);
    console.log('Tags formatadas para Jekyll relative_url com type attribute.');
}

main();
