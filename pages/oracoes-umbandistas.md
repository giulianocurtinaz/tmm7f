---
layout: page
title: "Orações Umbandistas"
date: 2020-05-13
---

“*Ao procurar por livros contendo orações umbandísticas me deparei com uma grande carência literária. Como faz parte da missão desta casa divulgar o Evangelho do Cristo e “ensinar” o homem comum a rezar, procuramos incentivar em nossa corrente a prática da oração. Assim sendo, a cada data comemorativa de algum Orixá, sempre que possível, nossos médiuns produzem orações, pois acreditamos que uma das maiores oferendas que podemos dar aos orixás são nossos melhores pensamentos e sentimentos. Espero que com o passar do anos, essas páginas se inundem de orações e quem sabe bem no futuro um livro que inspire pessoas a encontrar sua própria espiritualidade.*“

<div class="row listrecent mt-4">
{% for oracao in site.oracoes %}
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100 shadow-sm border-0">
      {% if oracao.image and oracao.image != "" %}
      <a href="{{ oracao.link | default: oracao.url | relative_url }}">
        <img class="img-fluid w-100" style="object-fit: cover; height: 200px;" src="{{ site.baseurl }}{{ oracao.image }}" alt="{{ oracao.title }}">
      </a>
      {% endif %}
      <div class="card-body">
        <h4 class="card-title text-center mb-1">
          <a class="text-dark" href="{{ oracao.link | default: oracao.url | relative_url }}">{{ oracao.title }}</a>
        </h4>
        {% if oracao.category %}
        <p class="card-text text-center text-muted small">{{ oracao.category }}</p>
        {% endif %}
      </div>
      <div class="card-footer bg-white border-0 text-center pb-4">
        <a href="{{ oracao.link | default: oracao.url | relative_url }}" class="btn btn-outline-success btn-sm">Ler Orações</a>
      </div>
    </div>
  </div>
{% endfor %}
</div>

<br>
<hr>
<p style="text-align: center;">
  <strong>Destaque:</strong> <a href="{{ '/assets/pdf/guia-rapido-umbandista.pdf' | relative_url }}" target="_blank">Baixe o Guia Rápido Umbandista</a>
</p>

<!-- rebuild: 2026-01-05-fix-guia-link -->
