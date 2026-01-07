---
layout: page
title: Pontos Cantados
permalink: /pontos-cantados/
---
<header>
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
<div class="wp-block-file"><a id="wp-block-file--media-52843753-db81-4405-a73b-20f8dc08621c" href="https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.docx">Pontos_Cantados DOC</a><a href="https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.docx" class="wp-block-file__button wp-element-button" download="" aria-describedby="wp-block-file--media-52843753-db81-4405-a73b-20f8dc08621c">Baixar</a></div>
<div class="wp-block-file"><a id="wp-block-file--media-0e316be2-8088-4e15-bd04-d392ec122271" href="https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.pdf">Pontos_Cantados PDF</a><a href="https://terreira6d2a4f868b.files.wordpress.com/2021/03/pontos_cantados.pdf" class="wp-block-file__button wp-element-button" download="" aria-describedby="wp-block-file--media-0e316be2-8088-4e15-bd04-d392ec122271">Baixar</a></div>
<p>Ajude-nos no desenvolvimento desse trabalho, entrando em contato pelo email terreira@maemariaseteflechas.com.br ou
    pelo Facebook.</p>
</header>

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
    .sidebar-filter { width: 100%; position: relative; top: 0; }
    .filter-nav { flex-direction: row; flex-wrap: wrap; justify-content: center; }
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
      <button class="filter-btn" onclick="filterPoints('Oxalá', this)">🕊️ Oxalá</button>
      <button class="filter-btn" onclick="filterPoints('Iemanjá', this)">🌊 Iemanjá</button>
      <button class="filter-btn" onclick="filterPoints('Oxum', this)">🍯 Oxum</button>
      <button class="filter-btn" onclick="filterPoints('Oxóssi', this)">🏹 Oxóssi</button>
      <button class="filter-btn" onclick="filterPoints('Xangô', this)">⚒️ Xangô</button>
      <button class="filter-btn" onclick="filterPoints('Iansã', this)">⚡ Iansã</button>
      <button class="filter-btn" onclick="filterPoints('Ogum', this)">⚔️ Ogum</button>
      <button class="filter-btn" onclick="filterPoints('Pretos Velhos', this)">☕ Pretos Velhos</button>
      <button class="filter-btn" onclick="filterPoints('Oriente', this)">🕌 Oriente</button>
      <button class="filter-btn" onclick="filterPoints('Diversos', this)">🌀 Diversos</button>
    </nav>
  </aside>

  <main class="content-points">

<div class="lista-pontos">

<!-- Inicio Loop Dinamico -->
{% assign pontos_ordenados = site.pontos | sort: 'ordenacao' %}
{% for ponto in pontos_ordenados %}
  <article class="ponto-cantado" id="ponto-{{ ponto.id_ponto }}" data-category="{{ ponto.category }}">
    <h2>{{ ponto.id_ponto }} - {{ ponto.title }}</h2>
    <div class="letra">
      {{ ponto.content | markdownify }}
      {% if ponto.audios %}
        {% for audio in ponto.audios %}
        <figure class="wp-block-audio">
          <audio controls src="{{ audio.url | relative_url }}"></audio>
          {% if audio.caption %}
          <figcaption class="wp-element-caption">{{ audio.caption }}</figcaption>
          {% endif %}
        </figure>
        {% endfor %}
      {% endif %}
    </div>
  </article>
{% endfor %}
<!-- Fim Loop Dinamico -->

</div>
  </main>
</div>

<script>
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

  if(window.innerWidth < 768) window.scrollTo(0,0);
}
</script>