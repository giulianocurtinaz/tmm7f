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
      <a class="filter-btn" href="#hinos">📜 Hinos</a>
      <a class="filter-btn" href="#oxala">🕊️ Oxalá</a>
      <a class="filter-btn" href="#iemanja">🌊 Iemanjá</a>
      <a class="filter-btn" href="#oxum">🍯 Oxum</a>
      <a class="filter-btn" href="#oxossi">🏹 Oxóssi</a>
      <a class="filter-btn" href="#xango">⚒️ Xangô</a>
      <a class="filter-btn" href="#iansa">⚡ Iansã</a>
      <a class="filter-btn" href="#ogum">⚔️ Ogum</a>
      <a class="filter-btn" href="#cosme">🍬 Cosme</a>
      <a class="filter-btn" href="#oriente">🕌 Oriente</a>
      <a class="filter-btn" href="#pretos-velhos">☕ Pretos Velhos</a>
      <a class="filter-btn" href="#diversos">🌀 Diversos</a>
    </nav>
  </aside>

  <main class="content-points">

<div class="lista-pontos">

<!-- Inicio Loop Agrupado por Categoria -->
{% assign all_points = site.pontos | sort: 'ordenacao' %}
{% assign categories = "Hinos,Oxalá,Iemanjá,Oxum,Oxóssi,Xangô,Iansã,Ogum,Cosme,Oriente,Pretos Velhos,Diversos" | split: "," %}

{% for cat in categories %}
  {% assign slug_cat = cat | slugify %}
  {% assign category_points = all_points | where: "category", cat %}
  
  {% if category_points.size > 0 %}
    <section id="{{ slug_cat }}" class="category-section">
      <h3 class="category-title">{{ cat }}</h3>
      
      {% for ponto in category_points %}
        <article class="ponto-cantado" id="ponto-{{ ponto.id_ponto }}">
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
      <hr>
    </section>
  {% endif %}
{% endfor %}
<!-- Fim Loop Agrupado -->

</div>
  </main>
</div>

<style>
  .category-title {
    background: #f0f7ff;
    padding: 10px;
    border-left: 5px solid #2196F3;
    margin-top: 30px;
    margin-bottom: 20px;
    color: #2196F3;
  }
</style>