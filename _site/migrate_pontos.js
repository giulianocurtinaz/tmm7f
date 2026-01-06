const fs = require('fs');
const path = require('path');

// Target the ROOT file which contains the structured HTML
const inputFile = 'pontos-cantados.md';
const outputDir = '_pontos';

if (!fs.existsSync(outputDir)) {
    try {
        fs.mkdirSync(outputDir);
    } catch (e) {
        console.log("Directory already exists or error: " + e);
    }
}

let content = "";
try {
    content = fs.readFileSync(inputFile, 'utf8');
} catch (e) {
    console.error("Could not find input file: " + inputFile);
    process.exit(1);
}

// Regex matching <article> tags
const articleRegex = /<article class="ponto-cantado" id="([^"]+)" data-category="([^"]+)">([\s\S]*?)<\/article>/g;

let match;
let count = 0;
while ((match = articleRegex.exec(content)) !== null) {
    const id = match[1].replace('ponto-', '');
    const category = match[2];
    const body = match[3];

    // Extract Title from h2
    const titleMatch = body.match(/<h2>(.*?)<\/h2>/);
    const title = titleMatch ? titleMatch[1] : 'Untitled';

    // Extract Lyrics (div class letra)
    const letraMatch = body.match(/<div class="letra">([\s\S]*?)<\/div>/);
    let letra = letraMatch ? letraMatch[1].trim() : '';

    const audios = [];
    // Audio regex
    const audioRegex = /<figure class="wp-block-audio"><audio controls(?:="")? src="([^"]+)"[^>]*><\/audio>\s*(?:<figcaption[^>]*>(.*?)<\/figcaption>)?\s*<\/figure>/g;

    let letraClean = letra;
    let audioMatch;

    while ((audioMatch = audioRegex.exec(letra)) !== null) {
        let url = audioMatch[1];

        // Clean liquid filter
        url = url.replace(/^{{\s*'/, "").replace(/'\s*\|\s*relative_url\s*}}$/, "");

        const caption = audioMatch[2] ? audioMatch[2].trim() : '';
        audios.push({ url, caption });

        letraClean = letraClean.replace(audioMatch[0], '');
    }

    let fm = `---
layout: ponto
id_ponto: "${id}"
title: "${title}"
category: "${category}"
`;
    if (audios.length > 0) {
        fm += `audios:\n`;
        audios.forEach(a => {
            fm += `  - url: "${a.url}"\n`;
            if (a.caption) fm += `    caption: "${a.caption}"\n`;
        });
    }
    fm += `---\n\n${letraClean.trim()}\n`;

    const filename = `ponto-${id}.md`;
    fs.writeFileSync(path.join(outputDir, filename), fm);
    count++;
}
console.log(`Extracted ${count} pontos.`);
