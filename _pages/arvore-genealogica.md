---
layout: page
title: "Árvore Genealógica"
permalink: /arvore-genealogica/
---

<style>
  .tree-wrapper {
    width: 100%;
    height: 70vh;
    border: 1px solid #ddd;
    border-radius: 8px;
    overflow: hidden;
    position: relative;
    background: #f9f9f9;
    cursor: grab;
    margin-bottom: 2rem;
  }
  .tree-wrapper:active {
    cursor: grabbing;
  }
  .tree-wrapper svg {
    width: 100%;
    height: 100%;
  }
  
  /* Tooltip */
  #tooltip {
    position: absolute;
    background: rgba(0, 0, 0, 0.9);
    color: white;
    padding: 15px;
    border-radius: 8px;
    font-size: 14px;
    pointer-events: none;
    display: none;
    z-index: 1000;
    box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    max-width: 320px;
  }
  #tooltip h4 {
    margin: 0 0 10px 0;
    color: #ffd700;
    font-size: 16px;
    border-bottom: 1px solid #555;
    padding-bottom: 5px;
  }
  #tooltip ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  #tooltip li {
    margin-bottom: 5px;
    line-height: 1.4;
  }
  #tooltip li strong {
    color: #ccc;
  }

  /* Node Labels */
  .node text {
    font-size: 14px;
    font-family: inherit;
    cursor: pointer;
    fill: #333;
    transition: fill 0.2s;
  }
  .node text:hover {
    fill: #007bff;
    text-decoration: underline;
  }
  .node circle {
    fill: #fff;
    stroke: #aaa;
    stroke-width: 2.5px;
    cursor: pointer;
    transition: fill 0.2s, stroke 0.2s;
  }
  .node circle.has-children {
    fill: #007bff;
    stroke: #007bff;
  }
  .node circle:hover {
    stroke: #0056b3;
    fill: #0056b3;
  }
  .link {
    fill: none;
    stroke: #ccc;
    stroke-width: 2px;
  }
  
  /* Modal Image Adjustment */
  #modal-image {
    max-width: 100%;
    height: auto;
    border-radius: .25rem;
  }
</style>

<div class="row">
    <div class="col-md-12">
        <p>Explore a árvore genealógica de nossa fraternidade. Você pode <strong>clicar e arrastar</strong> para mover a visualização (pan) e usar o scroll do mouse para <strong>aproximar e afastar</strong> (zoom). <strong>Clique nos círculos azuis</strong> para expandir ou recolher as ramificações, e <strong>clique no nome da terreira</strong> para ver detalhes e resgates históricos.</p>
    </div>
</div>

<div class="tree-wrapper" id="tree-container">
  <div id="tooltip"></div>
</div>

<!-- Modal para Detalhes do Centro -->
<div class="modal fade" id="detailsModal" tabindex="-1" role="dialog" aria-labelledby="detailsModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="detailsModalLabel">Detalhes do Centro</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Fechar" onclick="fecharModal()">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <div id="modal-image-container" class="text-center mb-4" style="display:none;">
          <img id="modal-image" src="" class="img-fluid rounded shadow" style="max-height: 350px; object-fit: cover;" alt="Capa da Terreira">
        </div>
        <div id="modal-content-container" class="content-body">
          <!-- O texto do markdown compilado será inserido aqui -->
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="fecharModal()">Fechar</button>
      </div>
    </div>
  </div>
</div>

<!-- Scripts -->
<script type="module">
  import * as d3 from 'https://cdn.jsdelivr.net/npm/d3@7/+esm';

  // Montagem segura dos dados via Liquid/Jekyll (o jsonify escapa tudo perfeitamente)
  const treeDataRaw = [
    {% for item in site.genealogia %}
    {
      "id": {{ item.codigo_final | jsonify }},
      "parentId": {{ item.codigo_pai | default: "" | jsonify }},
      "name": {{ item.nome_do_centro | default: "Desconhecido" | jsonify }},
      "dirigenteMaterial": {{ item.dirigente_material_fundador | jsonify }},
      "dirigenteEspiritual": {{ item.dirigente_espiritual_fundador | jsonify }},
      "ano": {{ item.ano_fundacao | jsonify }},
      "sucessoresEspirituais": {{ item.sucessores_espirituais | jsonify }},
      "sucessoresMateriais": {{ item.sucessores_materiais | jsonify }},
      "endereco": {{ item.endereco_atual | default: item.endereco_original | jsonify }},
      "foto_capa": {{ item.foto_capa | jsonify }},
      "content": {{ item.content | markdownify | jsonify }}
    }{% if forloop.last == false %},{% endif %}
    {% endfor %}
  ];

  window.fecharModal = function() {
    $('#detailsModal').modal('hide');
  };

  document.addEventListener("DOMContentLoaded", function() {
    const container = document.getElementById("tree-container");
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    const margin = {top: 20, right: 120, bottom: 20, left: 120};
    const dy = 60;  // Distância vertical entre nós
    const dx = 280; // Distância horizontal

    const svg = d3.select("#tree-container").append("svg")
        .attr("width", "100%")
        .attr("height", "100%");

    const inner = svg.append("g");
    
    const zoom = d3.zoom()
        .scaleExtent([0.1, 4])
        .on("zoom", (event) => {
            inner.attr("transform", event.transform);
        });
    svg.call(zoom);

    // Preparar dados (Stratify)
    const stratify = d3.stratify()
        .id(d => d.id)
        .parentId(d => d.parentId);

    let root;
    try {
        root = stratify(treeDataRaw);
    } catch(e) {
        console.error("Erro ao estruturar a árvore:", e);
        inner.append("text").attr("x", 50).attr("y", 50).text("Erro de estrutura hierárquica. Faltando nós pais.");
        return;
    }

    const tree = d3.tree().nodeSize([dy, dx]);
    const diagonal = d3.linkHorizontal().x(d => d.y).y(d => d.x);

    root.x0 = height / 2;
    root.y0 = 0;

    let i = 0;

    function update(source) {
        const treeData = tree(root);
        const nodes = treeData.descendants();
        const links = treeData.links();

        const transition = svg.transition().duration(400);

        // UPDATE NODES
        const node = inner.selectAll("g.node")
            .data(nodes, d => d.id || (d.id = ++i));

        const nodeEnter = node.enter().append("g")
            .attr("class", "node")
            .attr("transform", d => `translate(${source.y0},${source.x0})`);

        // Círculo
        nodeEnter.append("circle")
            .attr("r", 6)
            .attr("class", d => d._children ? "has-children" : "") 
            .on("click", (event, d) => {
                if (d.children) {
                    d._children = d.children;
                    d.children = null;
                } else {
                    d.children = d._children;
                    d._children = null;
                }
                update(d);
            });

        // Nome / Label
        nodeEnter.append("text")
            .attr("dy", ".35em")
            .attr("x", d => d.children || d._children ? -13 : 13)
            .attr("text-anchor", d => d.children || d._children ? "end" : "start")
            .text(d => d.data.name)
            .on("click", (event, d) => {
                abrirDetalhes(d.data);
            });
            
        // Tooltip
        nodeEnter.append("rect")
            .attr("y", -10)
            .attr("x", d => d.children || d._children ? -d.data.name.length*8 - 15 : 10)
            .attr("width", d => Math.max(d.data.name.length * 8, 50))
            .attr("height", 20)
            .attr("fill", "transparent")
            .style("cursor", "crosshair")
            .on("mouseover", (event, d) => showTooltip(event, d.data))
            .on("mousemove", (event) => moveTooltip(event))
            .on("mouseout", hideTooltip);

        const nodeUpdate = nodeEnter.merge(node);
        nodeUpdate.select("circle")
            .attr("class", d => d._children ? "has-children" : (d.children ? "has-children" : ""));

        nodeUpdate.transition(transition)
            .attr("transform", d => `translate(${d.y},${d.x})`);

        const nodeExit = node.exit().transition(transition)
            .attr("transform", d => `translate(${source.y},${source.x})`)
            .remove();

        nodeExit.select("circle").attr("r", 0);
        nodeExit.select("text").style("fill-opacity", 0);

        // UPDATE LINKS
        const link = inner.selectAll("path.link")
            .data(links, d => d.target.id);

        const linkEnter = link.enter().insert("path", "g")
            .attr("class", "link")
            .attr("d", d => {
                const o = {x: source.x0, y: source.y0};
                return diagonal({source: o, target: o});
            });

        link.merge(linkEnter).transition(transition)
            .attr("d", diagonal);

        link.exit().transition(transition)
            .attr("d", d => {
                const o = {x: source.x, y: source.y};
                return diagonal({source: o, target: o});
            })
            .remove();

        nodes.forEach(d => {
            d.x0 = d.x;
            d.y0 = d.y;
        });
    }

    const tooltip = d3.select("#tooltip");

    function showTooltip(event, data) {
      if(!data) return;
      tooltip.style("display", "block").html(`
        <h4>${data.name}</h4>
        <ul>
            <li><strong>Fundação:</strong> ${data.ano || 'N/A'}</li>
            <li><strong>Dirigente Material:</strong> ${data.dirigenteMaterial || 'Não informado'}</li>
            <li><strong>Dirigente Espiritual:</strong> ${data.dirigenteEspiritual || 'Não informado'}</li>
            <li><strong>Sucessores:</strong> <br><small>Material:</small> ${data.sucessoresMateriais || '-'} <br><small>Espiritual:</small> ${data.sucessoresEspirituais || '-'}</li>
            <li><strong>Endereço:</strong> ${data.endereco || 'Não informado'}</li>
        </ul>
      `);
    }
    
    function moveTooltip(event) {
      const containerRect = document.getElementById('tree-container').getBoundingClientRect();
      let left = event.clientX - containerRect.left + 15;
      let top = event.clientY - containerRect.top + 15;
      
      const tooltipElem = document.getElementById('tooltip');
      if (left + tooltipElem.offsetWidth > containerRect.width) {
        left = event.clientX - containerRect.left - tooltipElem.offsetWidth - 15;
      }
      
      if (top + tooltipElem.offsetHeight > containerRect.height) {
        top = event.clientY - containerRect.top - tooltipElem.offsetHeight - 15;
      }
      tooltip.style("left", left + "px").style("top", top + "px");
    }

    function hideTooltip() {  tooltip.style("display", "none");  }

    function abrirDetalhes(data) {
        document.getElementById('detailsModalLabel').textContent = data.name;
        
        const imgContainer = document.getElementById('modal-image-container');
        const imgElem = document.getElementById('modal-image');
        
        if (data.foto_capa && data.foto_capa.trim() !== '') {
            let src = data.foto_capa;
            if (!src.startsWith('http') && !src.startsWith('{{ site.baseurl }}')) {
                src = \`{{ site.baseurl }}\${src.startsWith('/') ? '' : '/'}\${src}\`;
            }
            imgElem.src = src;
            imgContainer.style.display = 'block';
        } else {
            imgContainer.style.display = 'none';
        }

        const contentHtml = (data.content || '').trim() !== '' ? data.content : '<p><em>Nenhuma informação histórica cadastrada para esta fraternidade.</em></p>';
        document.getElementById('modal-content-container').innerHTML = contentHtml;

        if (typeof $ !== 'undefined' && $.fn.modal) {
            $('#detailsModal').modal('show');
        } else {
            alert(data.name + "\\n\\n" + data.content);
        }
    }

    svg.call(zoom.transform, d3.zoomIdentity.translate(margin.left + 50, height / 2));

    // Collapse children of all nodes except the root so the tree starts small, but user asked for expand/collapse interatividade. 
    // Initial standard is typically fully expanded or fully collapsed.
    // We'll leave fully expanded so everything is searchable visually initially, but can be collapsed.
    root.descendants().forEach(d => {
        d._children = d.children; // preserve state in case of collapsing
    });

    update(root);
  });
</script>
