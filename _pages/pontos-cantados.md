---
layout: page
title: Pontos Cantados
permalink: /pontos-cantados/
---

<p>Com o objetivo de preservar nossa cultura e criar um arquivo de pontos para as futuras gerações que dirigirão nossos
    terreiros no futuro. Senti a necessidade de publicar esse riquíssimo material desenvolvido em 2007 pelos nossos
    amigos Darcy Dias da Silveira e Alcimar Bairros Pereira.</p>
<p>Nossos irmão foram muito felizes ao reunirem em um único livro os pontos cantados por nossas terreiras. <strong>O
        objetivo agora, é dar continuidade a esse trabalho, enaltecendo o passado e construindo o futuro</strong>. </p>
<p>Assim sendo, peço humildemente ajuda aos irmãos umbandistas para literalmente <strong>"darmos voz ao
        passado"</strong>, <strong>adicionando a esse rico material novos arquivos de áudio!</strong> </p>
<p>Com a permissão do Astral superior e sob a orientação de nossos guias de Aruanda, peço que nos abençoem nesse novo
    movimento, tornando possível a construção desse arquivo cultural da nossa Umbanda. </p>
<p>Não vamos permitir que pontos belíssimos sejam esquecidos! Umbanda é movimento, é força, é luz que chega a todos!
    Vamos juntos resgatar nosso passado, permitindo a construção de um futuro mais próspero e forte de nossa Umbanda!
</p>
<p>Ponto cantado é força! É base, é pilar de sustenção para nosso futuro! Que nossos guias permitam a realização desse
    projeto aqui na terra!</p>
<p>Baixe gratuitamente o livro original de pontos:</p>

<div class="wp-block-file">
    <a id="wp-block-file--docx" href="{{ '/assets/docs/pontos_cantados.docx' | relative_url }}">Pontos_Cantados DOC</a>
    <a href="{{ '/assets/docs/pontos_cantados.docx' | relative_url }}" class="wp-block-file__button wp-element-button" download="">Baixar</a>
</div>

<div class="wp-block-file">
    <a id="wp-block-file--pdf" href="{{ '/assets/docs/pontos_cantados.pdf' | relative_url }}">Pontos_Cantados PDF</a>
    <a href="{{ '/assets/docs/pontos_cantados.pdf' | relative_url }}" class="wp-block-file__button wp-element-button" download="">Baixar</a>
</div>

<p>Ajude-nos no desenvolvimento desse trabalho, entrando em contato pelo email terreira@maemariaseteflechas.com.br ou
    pelo Facebook.</p>
    

<style>
  /* Layout Base */
  .layout-container { display: flex; gap: 30px; align-items: flex-start; }
  
  /* Menu Lateral Fixo */
  .sidebar-filter { 
    width: 220px; 
    position: sticky; 
    top: 20px; 
    background: #f9f9f9; 
    padding: 20px; 
    border-radius: 10px; 
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    max-height: calc(100vh - 40px);
    overflow-y: auto;
  }

  .sidebar-filter h3 { margin-top: 0; font-size: 1.2em; border-bottom: 2px solid #2196F3; padding-bottom: 10px; }

  .filter-nav { display: flex; flex-direction: column; gap: 8px; }

  .filter-btn { 
    text-align: left; background: white; border: 1px solid #ddd; 
    padding: 10px 15px; border-radius: 8px; cursor: pointer; 
    transition: 0.3s; font-size: 0.95em;
  }

  .filter-btn:hover { background: #f0f7ff; border-color: #2196F3; }
  .filter-btn.active { background: #2196F3; color: white; border-color: #0b7dda; font-weight: bold; }

  /* Área de Conteúdo */
  .content-points { flex: 1; min-width: 0; } /* min-width 0 prevents overflow issues */

  /* Ajuste para Celular */
  @media (max-width: 768px) {
    .layout-container { flex-direction: column; }
    .sidebar-filter { width: 100%; position: relative; top: 0; max-height: none; overflow-y: visible; }
    .filter-nav { flex-direction: row; flex-wrap: wrap; justify-content: center; }
  }

  /* Buscador Flutuante */
  .floating-search {
    position: fixed;
    bottom: 30px;
    right: 30px;
    background: #fff;
    padding: 15px;
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    z-index: 9999;
    width: 280px;
    border: 1px solid var(--tmm-verde-folha);
  }
  .floating-search h3 {
    margin-top: 0;
    font-size: 1.1em;
    color: var(--tmm-azul-profundo);
    margin-bottom: 10px;
  }
  @media (max-width: 768px) {
    .floating-search {
      bottom: 15px;
      right: 15px;
      width: calc(100% - 30px);
    }
  }
</style>

<div class="layout-container">
  
  <aside class="sidebar-filter">
    <h3>Categorias</h3>
    <nav class="filter-nav">
      <button class="filter-btn active" onclick="filterPoints('all', this)">✨ Todos</button>
      <button class="filter-btn no-audio-btn" onclick="filterPoints('no-audio', this)" style="border-color: #ff9800; color: #e65100;">⚠️ Sem Áudio</button>
      <hr style="margin: 10px 0; border: 0; border-top: 1px solid #ddd;">
      <button class="filter-btn" onclick="filterPoints('Hinos', this)">📜 Hinos</button>
      <button class="filter-btn" onclick="filterPoints('Oxala', this)">🕊️ Oxalá</button>
      <button class="filter-btn" onclick="filterPoints('Iemanja', this)">🌊 Iemanjá</button>
      <button class="filter-btn" onclick="filterPoints('Oxum', this)">🍯 Oxum</button>
      <button class="filter-btn" onclick="filterPoints('Oxossi', this)">🏹 Oxóssi</button>
      <button class="filter-btn" onclick="filterPoints('Xango', this)">⚒️ Xangô</button>
      <button class="filter-btn" onclick="filterPoints('Iansa', this)">⚡ Iansã</button>
      <button class="filter-btn" onclick="filterPoints('Ogum', this)">⚔️ Ogum</button>
      <button class="filter-btn" onclick="filterPoints('Cosme', this)">🍬 Cosme</button>
      <button class="filter-btn" onclick="filterPoints('Oriente', this)">🕌 Oriente</button>
      <button class="filter-btn" onclick="filterPoints('Pretos', this)">☕ Pretos</button>
      <button class="filter-btn" onclick="filterPoints('Outros', this)">🌀 Outros</button>
    </nav>
  </aside>

  <main class="content-points">

<div class="lista-pontos">

<!-- Inicio Loop Dinamico -->
{% assign pontos_ordenados = site.pontos | sort: 'ordenacao' %}
{% for ponto in pontos_ordenados %}
  <article class="ponto-cantado" id="ponto-{{ ponto.id_ponto }}" data-category="{{ ponto.category }}">
    <h2 class="tmm-ponto-title" style="margin-bottom: 20px;">
      <a href="{{ '/pontos/ponto-' | append: ponto.id_ponto | relative_url }}" style="text-decoration: none; color: inherit;">
        <span style="font-size: 0.85em; opacity: 0.9;">{{ ponto.id_ponto }}</span> - {{ ponto.title }}
      </a>
    </h2>
    <div class="letra tmm-ponto-letra" style="margin-bottom: {% if ponto.audios %}20px{% else %}40px{% endif %};">
      {{ ponto.content | markdownify }}
    </div>
    {% if ponto.audios %}
      <div class="tmm-ponto-audios" style="margin-bottom: 40px; padding: 20px;">
      {% for audio in ponto.audios %}
        <figure class="tmm-audio-card wp-block-audio" style="margin-bottom: 10px;">
          <audio controls src="{{ audio.url | relative_url }}"></audio>
          {% if audio.caption %}
          <figcaption class="wp-element-caption" style="text-align: center; font-style: italic; color: #666;">{{ audio.caption }}</figcaption>
          {% endif %}
        </figure>
      {% endfor %}
      </div>
    {% endif %}
  </article>
{% endfor %}
<!-- Fim Loop Dinamico -->

</div>
  </main>
</div>

<!-- Buscador Flutuante -->
<div class="floating-search">
  <h3>🔍 Buscar Ponto</h3>
  <input type="text" id="searchInput" placeholder="Digite uma palavra..." style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #ddd; margin-bottom: 10px; font-size: 0.95em;">
  <div style="display: flex; gap: 8px;">
    <button onclick="findText(false)" class="filter-btn" style="flex: 1; text-align: center; padding: 8px; background: #f0f0f0;">⬅️ Voltar</button>
    <button onclick="findText(true)" class="filter-btn" style="flex: 1; text-align: center; padding: 8px; background: var(--tmm-verde-folha); color: white;">Avançar ➡️</button>
  </div>
</div>

<script>
function findText(forward) {
  const text = document.getElementById('searchInput').value;
  if (!text) return;
  // window.find() returns true if found, false otherwise
  // parameters: text, caseSensitive, backwards, wrapAround
  const found = window.find(text, false, !forward, true);
  if (!found) {
    alert("Texto não encontrado.");
  }
}

function filterPoints(category, btn) {
  // Atualiza classe ativa
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');

  const points = document.querySelectorAll('.ponto-cantado');
  
  points.forEach(point => {
    // Verifica se o ponto tem a tag de áudio
    const hasAudio = point.querySelector('audio') !== null;
    
    if (category === 'all') {
      point.style.display = 'block';
    } 
    else if (category === 'no-audio') {
      // Lógica especial: mostra apenas se NÃO tiver áudio
      point.style.display = hasAudio ? 'none' : 'block';
    } 
    else {
      // Filtro por categoria normal
      point.style.display = point.getAttribute('data-category') === category ? 'block' : 'none';
    }
  });

  if(window.innerWidth < 768) {
     const content = document.querySelector('.content-points');
     if(content) {
        setTimeout(() => {
            content.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 50);
     }
  }
}
</script>