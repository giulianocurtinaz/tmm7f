const fs = require('fs');
const https = require('https');
const path = require('path');
const url = require('url');

const MISSING_FILES = [
    { "id": "050", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/7ondas_2.ogg" },
    { "id": "051", "version": 2, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2024/03/galera-esta-no-mar-vamos-todos-remar1.ogg" },
    { "id": "068", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/a_lua_vem_surgindo_ines.ogg" },
    { "id": "071", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/assovia_assovia.ogg" },
    { "id": "094", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/quem_manda_na_mata_eh_oxossi_ines.ogg" },
    { "id": "100", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2024/03/aslva-a-falange-do-caboclo-sete-flechsa.ogg" },
    { "id": "107", "version": 2, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/tupimirim.ogg" },
    { "id": "118", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/jureminha.ogg" },
    { "id": "124", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/12/quem-eh-de-aruanda-nao-eh-de-arue.ogg" },
    { "id": "132", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/moca_bonita_ines.ogg" },
    { "id": "138", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/no_alto_da_pedreira.ogg" },
    { "id": "145", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/kao_xango.ogg" },
    { "id": "145", "version": 2, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/xango_eh_meu_guia.ogg" },
    { "id": "149", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/bradou_na_aldeia.ogg" },
    { "id": "165", "version": 2, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/tremeterra.ogg" },
    { "id": "168", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/peguei_na_pemba2.ogg" },
    { "id": "173", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/ele_vem_do_sol.ogg" },
    { "id": "177", "version": 2, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/gira-gira-sua-estrela.ogg" },
    { "id": "196", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/12/ele-eh-filho-do-major-heitor.ogg" },
    { "id": "198", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/clarao-da-lua.ogg" },
    { "id": "235", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/ogum_iara_alcimar.ogg" },
    { "id": "239", "version": 1, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/eu_vi_clarear_o_dia.ogg" },
    { "id": "252", "version": 2, "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2024/03/oxossi-assobiou-la-no-humaita1.ogg" },
    {
        "id": "264",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/27-de-setembro.ogg"
    },
    {
        "id": "274",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/27_setembro.ogg"
    },
    {
        "id": "275",
        "version": 2,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/abre_a_porta_juliane.ogg"
    },
    {
        "id": "277",
        "version": 2,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2024/03/oh-joao-batista-enviado-de-jesus1.ogg"
    },
    {
        "id": "282",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/ori_do_oriente.ogg"
    },
    {
        "id": "290",
        "version": 2,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/la_no_alto_da_serra.ogg"
    },
    {
        "id": "293",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/preto_velho_senta_no_toco.ogg"
    },
    {
        "id": "297",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/que_quere_que_que_preto_velho_de_bom_parecer.ogg"
    },
    {
        "id": "298",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/vovo_nao_quer_casca_de_coco.ogg"
    },
    {
        "id": "299",
        "version": 2,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/eu-vi-no-cecc81u-uma-estrela-correndo.ogg"
    },
    {
        "id": "303",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/pai_jose.ogg"
    },
    {
        "id": "309",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/la_no_ceu_brilhou.ogg"
    },
    {
        "id": "327",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/tumbeiro.ogg"
    },
    {
        "id": "333",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/ouvi_o_rufar_dos_tambores.ogg"
    },
    {
        "id": "341",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/nega_mina.ogg"
    },
    {
        "id": "344",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/o_preta_velha_voce_nao_me_engana.ogg"
    },
    {
        "id": "352",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/pai_bento_que_veio_de_aruanda.ogg"
    },
    {
        "id": "354",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/aruerira_de_pai_benedito.ogg"
    },
    {
        "id": "358",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/pai_oxala_mandou_pai_tome.ogg"
    },
    {
        "id": "362",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/oh_povo_de_umbanda.ogg"
    },
    {
        "id": "375",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/07/oh_estrela_do_ceu.ogg"
    },
    {
        "id": "376",
        "version": 2,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2024/03/santo-antonio-que-eh-de-ouro-fino1.ogg"
    },
    {
        "id": "378",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/deus_que_salve_nossos_guias.ogg"
    },
    {
        "id": "393",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/03/de_joelhos.ogg"
    },
    {
        "id": "402",
        "version": 1,
        "originalUrl": "https://terreira6d2a4f868b.files.wordpress.com/2021/04/amizade.ogg"
    }
];

const TARGET_MD = 'pontos-cantados.md';
const AUDIO_DIR = path.join('assets', 'audio');

// Headers to simulate browser
const HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7'
};

const SLEEP_MS = 300;

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function downloadFile(urlStr, destPath) {
    return new Promise((resolve, reject) => {
        const req = https.get(urlStr, { headers: HEADERS }, (res) => {
            if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
                // Redirect
                const newUrl = new URL(res.headers.location, urlStr).href; // Handle relative redirects
                // resolve(downloadFile(newUrl, destPath)); // Recursion
                // Avoid deep recursion stack issues, just return promise
                downloadFile(newUrl, destPath).then(resolve).catch(reject);
                return;
            }

            if (res.statusCode !== 200) {
                reject(new Error(`Status ${res.statusCode}`));
                return;
            }

            const file = fs.createWriteStream(destPath);
            res.pipe(file);
            file.on('finish', () => {
                file.close(() => resolve(true));
            });
            file.on('error', (err) => {
                fs.unlink(destPath, () => reject(err));
            });
        });

        req.on('error', (err) => {
            reject(err);
        });
        req.end();
    });
}

function getMimeType(filename) {
    const ext = path.extname(filename).toLowerCase();
    if (ext === '.ogg') return 'audio/ogg';
    if (ext === '.mp3') return 'audio/mpeg';
    if (ext === '.wav') return 'audio/wav';
    if (ext === '.m4a') return 'audio/mp4';
    return 'audio/mpeg';
}

async function tryRecover(item) {
    const extensions = ['.ogg', '.mp3', '.wav', '.m4a'];
    const originalExt = path.extname(new URL(item.originalUrl).pathname).toLowerCase();

    // Sort extensions to try original first
    const tryExts = [originalExt, ...extensions.filter(e => e !== originalExt)];

    // Also consider trying stripped clean URL if the original has weird path chars (rare)

    for (const ext of tryExts) {
        // Construct URL with this extension
        // This is tricky: changing extension on the URL side is a guess.
        // It's better to try to download the original URL first (done by first iter).
        // Then try replacing the extension in the URL.

        let targetUrl = item.originalUrl;
        if (ext !== originalExt) {
            targetUrl = item.originalUrl.replace(originalExt, ext);
        }

        const filename = `ponto-${item.id}-v${item.version}${ext}`;
        const dest = path.join(AUDIO_DIR, filename);

        console.log(` Tentando: ${targetUrl} -> ${filename}`);

        try {
            await downloadFile(targetUrl, dest);

            // Check if file size > 0 (some 404 pages return 200 OK HTML)
            const stats = fs.statSync(dest);
            if (stats.size < 1000) { // arbitrary small size for error page
                throw new Error('File too small (likely error page)');
            }

            console.log(`  Sucesso! Baixado: ${filename}`);
            return { success: true, filename: filename, mime: getMimeType(filename) };
        } catch (err) {
            // Cleanup failed attempt
            if (fs.existsSync(dest)) fs.unlinkSync(dest);
            // console.log(`  Falha (${ext}): ${err.message}`);
        }

        await sleep(SLEEP_MS);
    }

    return { success: false };
}

async function main() {
    let recoveredCount = 0;
    let mdContent = fs.readFileSync(TARGET_MD, 'utf-8');
    const failures = [];

    console.log(`Iniciando recuperação de ${MISSING_FILES.length} arquivos...`);

    for (const item of MISSING_FILES) {
        process.stdout.write(`Processando ID ${item.id} v${item.version}...`);

        const result = await tryRecover(item);

        if (result.success) {
            recoveredCount++;

            // Update Markdown
            // Search for: src="{{ '/assets/audio/ponto-ID-vVER.*' | relative_url }}"
            // Regex must be careful with dots and quotes
            const regex = new RegExp(`src="{{ '/assets/audio/ponto-${item.id}-v${item.version}\\.[^']+' \\| relative_url }}"`, 'g');

            // Since we know exactly what we are looking for (the BROKEN link), we need to know what the broken link WAS.
            // The previous script standardized on extensions (mostly .ogg if source was ogg).
            // But we can just use a broader regex to capture any extension for this ID/Version.

            const newTag = `src="{{ '/assets/audio/${result.filename}' | relative_url }}" type="${result.mime}"`;

            // Replace the src="..." part.
            // We also need to update the type="..." part if it exists or add it.
            // The existing tag format: <audio controls="" src="..." type="..."></audio>

            // Let's replace the whole tag logic for this specific file or just the src/type combo.
            // Check if match exists
            if (mdContent.match(regex)) {
                // Replace just the src line first
                mdContent = mdContent.replace(regex, `src="{{ '/assets/audio/${result.filename}' | relative_url }}"`);

                // Then update type. Finding the specific type attribute for this audio tag is hard with global replace.
                // Ideally we replace the whole block `<audio ... src="..." ...>`.
                // Let's try matching the src and the type next to it.
                // <audio controls="" src="{{ ... }}" type="audio/ogg"></audio>

                const typeRegex = new RegExp(`(src="{{ '/assets/audio/${result.filename}' \\| relative_url }}")\\s+type="[^"]+"`);
                mdContent = mdContent.replace(typeRegex, `$1 type="${result.mime}"`);
            } else {
                console.warn(`! Não foi possível atualizar MD para ${item.id} (Tag não encontrada pelo Regex)`);
            }

        } else {
            console.log(' Falhou todas as tentativas.');
            failures.push(item.id);
        }
    }

    fs.writeFileSync(TARGET_MD, mdContent, 'utf-8');

    console.log('\n--- Relatório Final ---');
    console.log(`Recuperados: ${recoveredCount}`);
    console.log(`Falhas Persistentes: ${failures.length}`);
    if (failures.length > 0) {
        console.log(`IDs com falha: ${failures.join(', ')}`);
    }
}

main();
