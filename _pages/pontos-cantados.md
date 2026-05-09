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

  /* Filtro Flutuante (Mobile) */
  .floating-filter-container {
    position: fixed;
    bottom: 30px;
    left: 30px;
    z-index: 9998;
    display: none; /* Escondido por padrão na web e quando no topo */
    flex-direction: column;
    align-items: flex-start;
  }
  @media (max-width: 768px) {
    .floating-filter-container.visible {
      display: flex;
    }
    .floating-filter-container {
      bottom: 15px;
      left: 15px;
    }
  }

  .floating-filter-toggle {
    background: #2196F3;
    color: white;
    border: none;
    border-radius: 50%;
    width: 60px;
    height: 60px;
    font-size: 24px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    cursor: pointer;
    transition: transform 0.3s, background 0.3s;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .floating-filter-toggle:hover {
    transform: scale(1.05);
    background: #0b7dda;
  }
  .floating-filter-panel {
    background: #fff;
    padding: 15px;
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    width: 280px;
    max-height: 60vh;
    overflow-y: auto;
    border: 1px solid #2196F3;
    margin-bottom: 15px;
    display: none;
  }
  @media (max-width: 768px) {
    .floating-filter-panel {
      width: calc(100vw - 30px);
      max-width: 320px;
    }
  }

  /* Buscador Flutuante Colapsável */
  .floating-search-container {
    position: fixed;
    bottom: 30px;
    right: 30px;
    z-index: 9999;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
  }
  .floating-search-toggle {
    background: var(--tmm-verde-folha);
    color: white;
    border: none;
    border-radius: 50%;
    width: 60px;
    height: 60px;
    font-size: 24px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    cursor: pointer;
    transition: transform 0.3s, background 0.3s;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .floating-search-toggle:hover {
    transform: scale(1.05);
    background: var(--tmm-verde-copa);
  }
  .floating-search-panel {
    background: #fff;
    padding: 15px;
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    width: 280px;
    border: 1px solid var(--tmm-verde-folha);
    margin-bottom: 15px;
    display: none; /* Escondido por padrão */
  }
  @media (max-width: 768px) {
    .floating-search-container {
      bottom: 15px;
      right: 15px;
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

  <!-- Sentinel element to trigger floating filter on mobile -->
  <div id="filter-sentinel"></div>

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

<!-- Buscador Flutuante Colapsável -->
<div class="floating-search-container">
  <div class="floating-search-panel" id="searchPanel">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
      <h3 style="margin: 0; font-size: 1.1em; color: var(--tmm-azul-profundo);">Buscar Ponto</h3>
      <button onclick="toggleSearch()" style="background: none; border: none; font-size: 1.5em; cursor: pointer; color: #888; padding: 0; line-height: 1;">&times;</button>
    </div>
    <input type="text" id="searchInput" placeholder="Digite uma palavra..." style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #ddd; margin-bottom: 10px; font-size: 0.95em;">
    <div style="display: flex; gap: 8px;">
      <button onclick="findText(false)" class="filter-btn" style="flex: 1; text-align: center; padding: 8px; background: #f0f0f0;">⬅️ Voltar</button>
      <button onclick="findText(true)" class="filter-btn" style="flex: 1; text-align: center; padding: 8px; background: var(--tmm-verde-folha); color: white;">Avançar ➡️</button>
    </div>
  </div>
  <button class="floating-search-toggle" onclick="toggleSearch()" aria-label="Abrir busca">
    <i class="fa-solid fa-magnifying-glass"></i>
  </button>
</div>

<!-- Filtro de Categorias Flutuante (Mobile) -->
<div class="floating-filter-container" id="floatingFilterContainer">
  <div class="floating-filter-panel" id="filterCategoryPanel">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">
      <h3 style="margin: 0; font-size: 1.1em; color: #2196F3;">Categorias</h3>
      <button onclick="toggleFilterCategory()" style="background: none; border: none; font-size: 1.5em; cursor: pointer; color: #888; padding: 0; line-height: 1;">&times;</button>
    </div>
    <nav class="filter-nav" id="floating-filter-nav">
      <!-- Injetado dinamicamente via JS -->
    </nav>
  </div>
  <button class="floating-filter-toggle" onclick="toggleFilterCategory()" aria-label="Abrir filtros">
    <i class="fa-solid fa-list"></i>
  </button>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // Clonar as categorias para o painel flutuante
    const originalNav = document.querySelector('.sidebar-filter .filter-nav');
    const floatingNav = document.getElementById('floating-filter-nav');
    if (originalNav && floatingNav) {
        floatingNav.innerHTML = originalNav.innerHTML;
    }

    // Usar IntersectionObserver para mostrar/esconder o botão no mobile
    const sentinel = document.getElementById('filter-sentinel');
    const floatingBtnContainer = document.getElementById('floatingFilterContainer');
    
    if ('IntersectionObserver' in window && sentinel && floatingBtnContainer) {
        const observer = new IntersectionObserver(entries => {
            // Quando o sentinela não estiver visível E a tela rolou para baixo dele
            if(entries[0].intersectionRatio === 0 && entries[0].boundingClientRect.top < 0) {
                floatingBtnContainer.classList.add('visible');
            } else {
                floatingBtnContainer.classList.remove('visible');
                document.getElementById('filterCategoryPanel').style.display = 'none'; // Fecha caso esteja aberto
            }
        });
        observer.observe(sentinel);
    }
});

function toggleSearch() {
  const panel = document.getElementById('searchPanel');
  if (panel.style.display === 'block') {
    panel.style.display = 'none';
  } else {
    panel.style.display = 'block';
    const input = document.getElementById('searchInput');
    if(input) input.focus();
  }
}

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

function toggleFilterCategory() {
  const panel = document.getElementById('filterCategoryPanel');
  if (panel.style.display === 'block') {
    panel.style.display = 'none';
  } else {
    panel.style.display = 'block';
  }
}

function filterPoints(category, btn) {
  // Sincroniza a classe ativa em ambos os menus (o principal e o flutuante)
  document.querySelectorAll('.filter-btn').forEach(b => {
    b.classList.remove('active');
    // Verifica se o onclick desse botão contém a mesma categoria
    if(b.getAttribute('onclick') && b.getAttribute('onclick').includes("'" + category + "'")) {
        b.classList.add('active');
    }
  });

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
            // Scroll considerando uma pequena folga para não esconder o topo atrás de algum header
            const yOffset = -20; 
            const y = content.getBoundingClientRect().top + window.pageYOffset + yOffset;
            window.scrollTo({top: y, behavior: 'smooth'});
        }, 50);
     }
     // Fecha o painel flutuante após selecionar no celular
     const panel = document.getElementById('filterCategoryPanel');
     if (panel) panel.style.display = 'none';
  }
}
</script>