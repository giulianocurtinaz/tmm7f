---
layout: default
title: Arquivo Histórico
permalink: /arquivo/
---

{% assign meses_pt = "Jan,Fev,Mar,Abr,Mai,Jun,Jul,Ago,Set,Out,Nov,Dez" | split: "," %}

{% comment %} Conta posts por ano {% endcomment %}
{% assign posts_por_ano = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% assign primeiro_ano = "9999" %}
{% assign ultimo_ano = "0000" %}
{% for grupo in posts_por_ano %}
  {% if grupo.name < primeiro_ano %}{% assign primeiro_ano = grupo.name %}{% endif %}
  {% if grupo.name > ultimo_ano %}{% assign ultimo_ano = grupo.name %}{% endif %}
{% endfor %}
{% assign anos_total = ultimo_ano | minus: primeiro_ano | plus: 1 %}
{% assign anos_ordenados = posts_por_ano | sort: "name" | reverse %}

<!-- ============================================
     CABEÇALHO DO ARQUIVO
     ============================================ -->
<header class="tmm-page-head tmm-arquivo__head">
    <div class="tmm-container">
        <span class="tmm-page-head__eyebrow">
            <i class="fa-solid fa-book-bible"></i> Histórico vivo da Terreira
        </span>
        <h1 class="tmm-page-head__title">Arquivo <em>Histórico</em></h1>
        <div class="tmm-divider">&#10022;</div>
        <p class="tmm-arquivo__lead">
            Tudo que registramos da nossa caminhada espiritual desde {{ primeiro_ano }}.
            Reflexões, homenagens, sessões marcantes, batizados e momentos de fé.
        </p>

        <div class="tmm-arquivo__stats">
            <div class="tmm-stat">
                <strong>{{ site.posts | size }}</strong>
                <span>posts publicados</span>
            </div>
            <div class="tmm-stat">
                <strong>{{ primeiro_ano }} – {{ ultimo_ano }}</strong>
                <span>período coberto</span>
            </div>
            <div class="tmm-stat">
                <strong>{{ anos_total }} anos</strong>
                <span>de história</span>
            </div>
        </div>
    </div>
</header>

<!-- ============================================
     CORPO DO ARQUIVO
     ============================================ -->
<section class="tmm-arquivo">
    <div class="tmm-container tmm-arquivo__inner">

        <div class="tmm-arquivo__toolbar">
            <div class="tmm-arquivo__search">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input
                    type="search"
                    id="tmm-arquivo-busca"
                    placeholder="Buscar no arquivo (ex: Iemanjá, Ogum, batizado…)"
                    aria-label="Buscar posts no arquivo"
                    autocomplete="off">
                <button type="button" class="tmm-arquivo__search-clear" id="tmm-arquivo-clear" aria-label="Limpar busca" hidden>
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="tmm-arquivo__filters" role="tablist" aria-label="Filtrar por ano">
                <button type="button" class="tmm-filter-btn is-active" data-filter-year="all">
                    Todos <span class="tmm-filter-count">{{ site.posts | size }}</span>
                </button>
                {% for grupo in anos_ordenados %}
                <button type="button" class="tmm-filter-btn" data-filter-year="{{ grupo.name }}">
                    {{ grupo.name }} <span class="tmm-filter-count">{{ grupo.items | size }}</span>
                </button>
                {% endfor %}
            </div>
        </div>

        <p class="tmm-arquivo__empty" id="tmm-arquivo-empty" hidden>
            <i class="fa-regular fa-face-frown"></i>
            Nenhum post encontrado com esses critérios.
        </p>

        <div class="tmm-arquivo__list" id="tmm-arquivo-list">
            {% for grupo in anos_ordenados %}
                <div class="tmm-arquivo__year" data-year="{{ grupo.name }}">
                    <h2 class="tmm-arquivo__year-title">
                        <span>{{ grupo.name }}</span>
                        <small>{{ grupo.items | size }} {% if grupo.items.size == 1 %}post{% else %}posts{% endif %}</small>
                    </h2>
                    <div class="tmm-arquivo__grid">
                        {% assign posts_ano = grupo.items | sort: "date" | reverse %}
                        {% for post in posts_ano %}
                            {% assign d = post.date | date: "%d-%m" | split: "-" %}
                            {% assign mes_idx = d[1] | times: 1 | minus: 1 %}
                            <article class="tmm-arquivo__card"
                                     data-year="{{ post.date | date: '%Y' }}"
                                     data-title="{{ post.title | downcase | escape }}"
                                     data-excerpt="{{ post.excerpt | strip_html | downcase | truncate: 200 | escape }}">
                                <a href="{{ post.url | relative_url }}" class="tmm-arquivo__card-link">
                                    <div class="tmm-arquivo__date">
                                        <span class="dia">{{ d[0] }}</span>
                                        <span class="mes">{{ meses_pt[mes_idx] }}</span>
                                    </div>
                                    <div class="tmm-arquivo__body">
                                        <h3>{{ post.title }}</h3>
                                        <p>{{ post.excerpt | strip_html | truncatewords: 22 }}</p>
                                        <span class="tmm-arquivo__readmore">
                                            Ler post <i class="fa-solid fa-arrow-right"></i>
                                        </span>
                                    </div>
                                </a>
                            </article>
                        {% endfor %}
                    </div>
                </div>
            {% endfor %}
        </div>

        <button type="button" class="tmm-arquivo__top" id="tmm-arquivo-top" aria-label="Voltar ao topo" hidden>
            <i class="fa-solid fa-arrow-up"></i>
        </button>
    </div>
</section>

<script>
(function () {
    var lista       = document.getElementById('tmm-arquivo-list');
    var inputBusca  = document.getElementById('tmm-arquivo-busca');
    var btnLimpar   = document.getElementById('tmm-arquivo-clear');
    var msgVazio    = document.getElementById('tmm-arquivo-empty');
    var btnTopo     = document.getElementById('tmm-arquivo-top');
    var filtros     = document.querySelectorAll('.tmm-filter-btn');
    if (!lista) return;

    var anoAtivo = 'all';
    var termoAtivo = '';

    function aplicarFiltros() {
        var termo = termoAtivo.trim().toLowerCase();
        var totalVisivel = 0;
        var grupos = lista.querySelectorAll('.tmm-arquivo__year');

        grupos.forEach(function (grupoEl) {
            var cards = grupoEl.querySelectorAll('.tmm-arquivo__card');
            var visiveisNoGrupo = 0;

            cards.forEach(function (card) {
                var anoOk = (anoAtivo === 'all' || anoAtivo === card.dataset.year);
                var termoOk = !termo
                    || card.dataset.title.indexOf(termo) !== -1
                    || card.dataset.excerpt.indexOf(termo) !== -1;
                var visivel = anoOk && termoOk;
                card.hidden = !visivel;
                if (visivel) visiveisNoGrupo++;
            });

            grupoEl.hidden = (visiveisNoGrupo === 0);
            totalVisivel += visiveisNoGrupo;
        });

        msgVazio.hidden = (totalVisivel > 0);
        btnLimpar.hidden = !termo;
    }

    filtros.forEach(function (btn) {
        btn.addEventListener('click', function () {
            filtros.forEach(function (b) { b.classList.remove('is-active'); });
            btn.classList.add('is-active');
            anoAtivo = btn.dataset.filterYear;
            aplicarFiltros();
            lista.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });
    });

    var debounceTimer;
    inputBusca.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function () {
            termoAtivo = inputBusca.value;
            aplicarFiltros();
        }, 150);
    });

    btnLimpar.addEventListener('click', function () {
        inputBusca.value = '';
        termoAtivo = '';
        aplicarFiltros();
        inputBusca.focus();
    });

    document.addEventListener('keydown', function (e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            inputBusca.focus();
            inputBusca.select();
        }
    });

    window.addEventListener('scroll', function () {
        btnTopo.hidden = (window.scrollY < 600);
    });
    btnTopo.addEventListener('click', function () {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });
})();
</script>
