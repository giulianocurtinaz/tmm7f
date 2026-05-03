# Guia de Desenvolvimento — Terreira de Mãe Maria · Sete Flechas

Este documento mostra como rodar o site **localmente** no seu computador (para ver as alterações antes de publicar) e como **publicar no GitHub** quando estiver tudo pronto.

---

## 1. O que você precisa instalado

O site é feito com **Jekyll** (gerador de sites estáticos em Ruby). Você precisa, uma única vez:

1. **Git** — já está instalado (você usa o GitHub).
2. **Ruby + RubyGems + Bundler + Jekyll** — para compilar o site localmente.

### Instalando Ruby + Jekyll no Windows (uma vez só)

1. Baixe o instalador **Ruby+Devkit** em <https://rubyinstaller.org/downloads/>
   (escolha a versão **3.2.x (x64) com Devkit** — recomendada)
2. Execute o instalador. Marque a opção **"MSYS2 development toolchain"** ao final.
3. Quando terminar, abra o **PowerShell** (ou Git Bash) e rode:

   ```powershell
   gem install bundler jekyll
   ```

4. Vá até a pasta do site e instale as dependências do projeto:

   ```powershell
   cd C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp
   bundle install
   ```

Pronto. Isso só precisa ser feito uma vez.

---

## 2. Rodando o site localmente

Toda vez que quiser ver as alterações no navegador antes de publicar:

```powershell
cd C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp
bundle exec jekyll serve --livereload
```

Aguarde algumas mensagens (a primeira compilação demora ~30 segundos por causa dos 405 pontos cantados). Quando aparecer:

```
Server address: http://127.0.0.1:4000/
Server running... press ctrl-c to stop.
```

Abra no navegador:

> **<http://localhost:4000>**

Agora **toda vez que você editar qualquer arquivo**, o site recompila sozinho e o navegador atualiza (graças ao `--livereload`).

Para parar o servidor, volte ao PowerShell e aperte `Ctrl + C`.

### Atalhos úteis

| Comando | O que faz |
|---|---|
| `bundle exec jekyll serve` | Roda o site em <http://localhost:4000> |
| `bundle exec jekyll serve --livereload` | Idem + atualiza navegador automático |
| `bundle exec jekyll serve --drafts` | Inclui rascunhos de `_drafts/` |
| `bundle exec jekyll build` | Apenas compila para `_site/` (sem servidor) |
| `bundle exec jekyll clean` | Apaga `_site/` e cache (resolve bugs estranhos) |

---

## 3. Visualizando o preview do novo design (sem precisar do Jekyll)

Para ver rapidamente como ficou o novo visual da home **sem** precisar compilar nada, basta abrir no navegador:

> **`preview-nova-home.html`**

(Está na raiz do projeto. É um arquivo HTML standalone com tudo embutido — fontes, CSS, mockup do conteúdo. Não tem Liquid nem dados reais, só serve para validar o visual.)

---

## 4. Publicando no GitHub (deploy)

O site usa **GitHub Pages**: tudo que você commitar na branch `main` aparece no <https://www.maemariaseteflechas.com.br> em ~1 minuto.

### Fluxo seguro recomendado, toda vez que for publicar

```powershell
# 1) Vai para a pasta
cd C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp

# 2) Verifica o que mudou
git status

# 3) Adiciona TUDO que mudou (cuidado: vai adicionar tudo que aparece em "Changes not staged")
git add .

# 4) Cria o commit com uma mensagem descritiva
git commit -m "novo design da home + tema floresta tropical"

# 5) Sobe para o GitHub (e por consequência, para o site)
git push origin main
```

Aguarde 1-2 minutos e atualize o site público para conferir.

### Ou rode o script automatizado

Veja a seção 5 abaixo.

---

## 5. Script automatizado de deploy (opcional)

Criei o script **`deploy.ps1`** na raiz do projeto. Ele faz tudo de uma vez:

- Mostra o que vai mudar
- Pede confirmação
- Faz commit com mensagem + data automática
- Faz push para o GitHub

### Como usar

```powershell
cd C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp
.\deploy.ps1 "minha mensagem de commit aqui"
```

Se você não passar mensagem, ele usa uma padrão com a data/hora.

---

## 6. Antes de subir mudanças, sempre puxe do GitHub primeiro

Se você editar algo direto no GitHub (pelo navegador) ou usar outro computador, sempre rode antes de começar a trabalhar:

```powershell
cd C:\Users\Giuliano\Desktop\GIULIANO\TMM7F\wp
git pull origin main
```

Isso traz para o seu PC tudo que está mais novo no GitHub.

---

## 7. Estrutura do projeto (visão rápida)

```
wp/
├── _config.yml              ← configurações do site (título, plugins, etc.)
├── _data/
│   ├── navigation.yml       ← itens do menu (legado)
│   └── calendario.yml       ← NOVO: agenda de sessões 2026
├── _layouts/
│   ├── default.html         ← layout padrão (com navbar e footer)
│   ├── home.html            ← NOVO: layout exclusivo da home (sem cabeçalho duplicado)
│   ├── page.html            ← NOVO design para páginas estáticas
│   ├── post.html            ← NOVO design para posts
│   ├── ponto.html           ← NOVO design para pontos cantados
│   └── genealogia.html      ← (mantido)
├── _posts/                  ← suas postagens (193 posts)
├── _pontos/                 ← pontos cantados (405 pontos)
├── _oracoes/                ← orações (6 coletâneas)
├── _genealogia/             ← árvore genealógica
├── _pages/                  ← páginas internas (Missão, Calendário, etc.)
├── assets/
│   ├── css/
│   │   ├── screen.css       ← CSS do tema antigo (Mediumish) — mantido
│   │   ├── main.scss        ← (legado)
│   │   └── tmm-theme.css    ← NOVO: tema "floresta tropical" da Terreira
│   ├── images/
│   │   ├── logo.png         ← (mantido)
│   │   └── logo-tmm7f.svg   ← NOVO: logo SVG da Terreira (vetorial)
│   └── js/
├── index.html               ← NOVA home (hero + cards + calendário + posts em grid)
├── preview-nova-home.html   ← Preview standalone para abrir direto no navegador
├── DESENVOLVIMENTO.md       ← este arquivo
├── deploy.ps1               ← script para publicar com 1 comando
└── ...
```

---

## 8. Como editar coisas comuns

### Adicionar um novo post

1. Crie um arquivo em `_posts/` com o nome no formato:
   `AAAA-MM-DD-titulo-com-tracos.md`
2. Comece com este cabeçalho:

   ```markdown
   ---
   layout: post
   title: "Título do Post"
   date: 2026-05-15
   image: "assets/images/foto-do-post.jpg"
   categories: [Eventos, Sessão]
   ---

   Aqui o conteúdo do post em Markdown.
   ```

### Atualizar a agenda do calendário

Edite `_data/calendario.yml` e adicione/edite eventos no formato:

```yaml
- data: "2026-05-17"
  titulo: "Homenagem aos Pretos-Velhos"
  descricao: "Sessão pública às 9h"
  tag: "Pretos-Velhos"
```

A home automaticamente mostra os 6 próximos eventos a partir da data atual.

### Trocar o logo

Substitua o arquivo `assets/images/logo-tmm7f.svg`. Ou se preferir um PNG/JPG, salve como `logo-tmm7f.png` e atualize as referências em `_layouts/default.html` e `index.html`.

### Mudar cores do tema

Edite o início de `assets/css/tmm-theme.css`. As variáveis CSS no `:root` controlam toda a paleta:

```css
:root {
    --tmm-verde-folha: #4d8f80;   /* cor principal (verde do logo) */
    --tmm-azul-profundo: #2e5d7a; /* títulos */
    /* ... */
}
```

Mude a variável e o site inteiro acompanha.

---

## 9. Problemas comuns

### "bundle: command not found"
Você não instalou o Ruby ainda. Volte para a seção 1.

### "Could not find gem ..." ao rodar `jekyll serve`
Rode `bundle install` na pasta do projeto.

### Mudei algo e não aparece no site
- Confira se o `jekyll serve` ainda está rodando.
- Se mudou `_config.yml`, precisa parar (Ctrl+C) e rodar `jekyll serve` de novo.
- Tente `bundle exec jekyll clean` e depois `jekyll serve`.

### "git push" pede senha e diz que falhou
Você precisa configurar autenticação no GitHub. O jeito mais fácil:

1. Instale o **GitHub CLI**: <https://cli.github.com>
2. Rode `gh auth login` e siga as instruções.

Ou use o **GitHub Desktop**: <https://desktop.github.com>

### O site público não atualizou após o push
Aguarde 1-2 minutos. Se passar 5 minutos, verifique a aba **Actions** no GitHub para ver se o build deu erro.

---

## 10. Atalhos de comandos mais usados

```powershell
# Ver mudanças locais
git status

# Ver as últimas alterações no servidor
git pull origin main

# Rodar localmente (com auto-reload)
bundle exec jekyll serve --livereload

# Publicar
.\deploy.ps1 "mensagem do commit"
```

---

**Pronto!** Em caso de dúvidas, peça ajuda no chat para o Claude do Cowork — ele tem contexto completo deste projeto.
