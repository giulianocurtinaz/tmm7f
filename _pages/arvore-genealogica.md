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
  
  #tooltip .tooltip-close {
    position: absolute;
    top: 10px;
    right: 10px;
    background: transparent;
    border: none;
    color: white;
    font-size: 16px;
    cursor: pointer;
  }
  
  #tooltip.sticky {
    pointer-events: auto;
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

<script type="application/json" id="tree-data">
[
  {% for item in site.genealogia %}
  {
    "id": {{ item.codigo_final | jsonify }},
    "parentId": {{ item.codigo_pai | default: "" | jsonify }},
    "name": {{ item.nome_do_centro | default: "Desconhecido" | jsonify }},
    "nome_simplificado": {{ item.nome_simplificado | jsonify }},
    "dirigenteMaterial": {{ item.dirigente_material_fundador | jsonify }},
    "dirigenteEspiritual": {{ item.dirigente_espiritual_fundador | jsonify }},
    "ano": {{ item.ano_fundacao | jsonify }},
    "sucessoresEspirituais": {{ item.sucessores_espirituais | jsonify }},
    "sucessoresMateriais": {{ item.sucessores_materiais | jsonify }},
    "endereco": {{ item.endereco_atual | default: item.endereco_original | jsonify }},
    "foto_capa": {{ item.foto_capa | jsonify }},
    "content": {{ item.content | markdownify | jsonify }},
    "url": {{ item.url | jsonify }}
  }{% if forloop.last == false %},{% endif %}
  {% endfor %}
]
</script>

<script src="https://cdn.jsdelivr.net/npm/d3@7"></script>
<script>
  function initTree() {
    console.log("DOM loaded. Inicializando D3 Genealogia...");

    // Montagem segura dos dados via Liquid/Jekyll
    let treeDataRaw = [];
    try {
      const jsonContent = document.getElementById("tree-data").textContent;
      let parsed = JSON.parse(jsonContent);
      
      // Compute short name for graph display
      parsed.forEach(node => {
        if (node.nome_simplificado && node.nome_simplificado.trim() !== '') {
          node.shortName = node.nome_simplificado;
        } else {
          // Fallback: Last two words of the full name
          let words = (node.name || "").trim().split(/\s+/);
          if (words.length > 2) {
             node.shortName = words.slice(-2).join(' ');
          } else {
             node.shortName = node.name;
          }
        }
      });
      treeDataRaw = parsed;

      console.log(`Sucesso: ${treeDataRaw.length} nós carregados da coleção "_genealogia".`);
    } catch(e) {
      console.error("ERRO CRÍTICO ao fazer parse dos dados da genealogia:", e);
      document.getElementById("tree-container").innerHTML = "<p style='color:red; padding:20px;'>Erro interno: Os dados da coleção genealogia contêm caracteres inválidos ou formatação errada.</p>";
      return;
    }

    const container = document.getElementById("tree-container");
    if (!container) {
      console.error("Container #tree-container não foi encontrado no HTML.");
      return;
    }

    const width = container.clientWidth || 800;
    const height = container.clientHeight || 600;
    
    const margin = {top: 20, right: 120, bottom: 20, left: 120};
    const dy = 60;  // Distância vertical entre nós
    const dx = 280; // Distância horizontal

    const svg = d3.select("#tree-container").append("svg")
        .attr("width", "100%")
        .attr("height", "100%")
        .style("background-color", "#f9f9f9");

    const inner = svg.append("g");
    
    const zoom = d3.zoom()
        .scaleExtent([0.1, 4])
        .on("zoom", (event) => {
            inner.attr("transform", event.transform);
        });
    svg.call(zoom);

    // Preparar dados (Stratify)
    const stratify = d3.stratify()
        .id(d => String(d.id).trim())
        .parentId(d => d.parentId ? String(d.parentId).trim() : "");

    let root;
    try {
        console.log("Tentando estruturar a árvore D3 (stratify)...");
        root = stratify(treeDataRaw);
        console.log("Árvore D3 estruturada com sucesso (root):", root.id);
    } catch(e) {
        console.error("ERRO CRÍTICO ao criar a hierarquia (D3 Stratify):", e);
        console.log("Dados que falharam:", treeDataRaw);
        inner.append("text").attr("x", 50).attr("y", 50).attr("fill", "red").text("Erro de estrutura hierárquica na Árvore. Verifique o F12 (Console).");
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
            .text(d => d.data.shortName)
            .style("cursor", "pointer")
            .style("pointer-events", "none"); // Let the rect handle the events
            
        // Tooltip container append (transparent rect acting as hitbox for text)
        nodeEnter.append("rect")
            .attr("y", -10)
            .attr("x", d => d.children || d._children ? -d.data.shortName.length*8 - 15 : 10)
            .attr("width", d => Math.max(d.data.shortName.length * 8, 50))
            .attr("height", 20)
            .attr("fill", "transparent")
            .style("cursor", "pointer")
            .on("mouseover", (event, d) => showTooltip(event, d.data, false))
            .on("mousemove", (event) => moveTooltip(event))
            .on("mouseout", () => hideTooltip(false))
            .on("click", (event, d) => {
                event.stopPropagation();
                toggleStickyTooltip(event, d.data);
            });

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

    let stickyTooltipNode = null;
    const tooltip = d3.select("#tooltip");

    function showTooltip(event, data, isSticky = false) {
      if(!data) return;
      if(stickyTooltipNode && !isSticky) return; // Don't override sticky with simple hover
      
      let closeBtn = isSticky ? `<button class="tooltip-close" onclick="closeStickyTooltip(event)">&times;</button>` : '';
      let linkHtml = isSticky ? `<div class="mt-4 text-center"><a href="${data.url}" class="btn btn-primary d-inline-block px-4 py-2 font-weight-bold" style="font-size: 15px; border-radius: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.3);">Ver história completa</a></div>` : '';
      
      tooltip.style("display", "block").html(`
        ${closeBtn}
        <h4 style="margin-right: 20px;">${data.name}</h4>
        <ul>
            <li><strong>Fundação:</strong> ${data.ano || 'N/A'}</li>
            <li><strong>Dirigente Material:</strong> ${data.dirigenteMaterial || 'Não informado'}</li>
            <li><strong>Dirigente Espiritual:</strong> ${data.dirigenteEspiritual || 'Não informado'}</li>
            <li><strong>Sucessores:</strong> <br><small>Material:</small> ${data.sucessoresMateriais || '-'} <br><small>Espiritual:</small> ${data.sucessoresEspirituais || '-'}</li>
            <li><strong>Endereço:</strong> ${data.endereco || 'Não informado'}</li>
        </ul>
        ${linkHtml}
      `);
      
      if(isSticky) {
          tooltip.classed("sticky", true);
      } else {
          tooltip.classed("sticky", false);
      }
    }
    
    function toggleStickyTooltip(event, data) {
      if (stickyTooltipNode === data) {
          closeStickyTooltip(event);
      } else {
          stickyTooltipNode = data;
          showTooltip(event, data, true);
          moveTooltip(event, true);
      }
    }

    window.closeStickyTooltip = function(event) {
        if(event) event.stopPropagation();
        stickyTooltipNode = null;
        tooltip.classed("sticky", false);
        tooltip.style("display", "none");
    };

    // Close sticky on outside click
    d3.select("body").on("click", (event) => {
        if (stickyTooltipNode && !event.target.closest('#tooltip') && !event.target.closest('text') && !event.target.closest('rect')) {
            window.closeStickyTooltip();
        }
    });
    
    function moveTooltip(event, forceUpdate = false) {
      if(stickyTooltipNode && !forceUpdate) return; // Don't move sticky
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

    function hideTooltip(isSticky = false) {  
        if(stickyTooltipNode && !isSticky) return;
        tooltip.style("display", "none");  
    }


    svg.call(zoom.transform, d3.zoomIdentity.translate(margin.left + 50, height / 2));

    // Collapse children of all nodes except the root so the tree starts small, but user asked for expand/collapse interatividade. 
    root.descendants().forEach(d => {
        d._children = d.children; // preserve state in case of collapsing
    });

    try {
        update(root);
        console.log("Árvore D3 renderizada com sucesso.");
    } catch (e) {
        console.error("ERRO ao renderizar os nós da árvore (D3 Update):", e);
    }
  } // Fim da function initTree()
  
  if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initTree);
  } else {
      initTree();
  }
</script>
