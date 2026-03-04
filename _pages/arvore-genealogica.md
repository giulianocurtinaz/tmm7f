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
    width: 100% !important;
    height: 100% !important;
  }
  /* Increase padding inside node labels */
  .node .label {
    padding: 15px 25px !important;
  }
  #tooltip {
    position: absolute;
    background: rgba(0, 0, 0, 0.85);
    color: white;
    padding: 10px 15px;
    border-radius: 5px;
    font-size: 14px;
    pointer-events: none;
    display: none;
    z-index: 1000;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    max-width: 300px;
  }
  #tooltip h4 {
    margin: 0 0 5px 0;
    color: #ffd700;
    font-size: 16px;
  }
  #tooltip p {
    margin: 0;
    line-height: 1.4;
  }
</style>

<div class="row">
    <div class="col-md-12">
        <p>Explore a árvore genealógica de nossa fraternidade. Você pode <strong>clicar e arrastar</strong> para mover a visualização (pan) e usar o scroll do mouse para <strong>aproximar e afastar</strong> (zoom). Passe o mouse sobre um centro para ver os fundadores.</p>
    </div>
</div>

<div class="tree-wrapper" id="tree-container">
  <div id="tooltip"></div>
  <div class="mermaid" id="genealogy-graph">
graph LR
{% for item in site.genealogia %}
  {% assign safe_name = item.nome_do_centro | replace: '"', '' | replace: '(', '' | replace: ')', '' %}
  {% if item.codigo_pai and item.codigo_pai != "" %}
  node{{ item.codigo_pai | replace: '.', '_' }} --> node{{ item.codigo_final | replace: '.', '_' }}["{{ safe_name }}"]
  {% else %}
  node{{ item.codigo_final | replace: '.', '_' }}["{{ safe_name }}"]
  {% endif %}
{% endfor %}
  </div>
</div>

<!-- Load scripts via ESM to properly import libraries -->
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
  import * as d3 from 'https://cdn.jsdelivr.net/npm/d3@7/+esm';

  const nodeData = {
    {% for item in site.genealogia %}
    "node{{ item.codigo_final | replace: '.', '_' }}": {
      "dirigente": "{{ item.dirigente_material_fundador | escape | replace: '\n', ' ' | replace: '\r', '' }}",
      "ano": "{{ item.ano_fundacao | escape }}"
    }{% if forloop.last == false %},{% endif %}
    {% endfor %}
  };

  mermaid.initialize({ 
    startOnLoad: true,
    theme: 'default',
    themeVariables: {
      fontSize: '20px'
    },
    useMaxWidth: false,
    securityLevel: 'loose',
    flowchart: {
      htmlLabels: true,
      curve: 'basis',
      padding: 30,
      nodeSpacing: 80,
      rankSpacing: 100
    }
  });

  document.addEventListener("DOMContentLoaded", function() {
    // Check periodically if the SVG has been injected by Mermaid
    const checkInterval = setInterval(() => {
      const svg = d3.select("#genealogy-graph svg");
      
      if (!svg.empty()) {
        clearInterval(checkInterval);
        
        const container = d3.select("#tree-container");
        const tooltip = d3.select("#tooltip");
        const inner = svg.select("g"); // The main group inside the SVG that holds all nodes

        // Configure Pan and Zoom via D3
        const zoom = d3.zoom()
          .scaleExtent([0.1, 4])
          .on("zoom", (event) => {
            inner.attr("transform", event.transform);
          });
        
        svg.call(zoom);

        // Tooltip logic
        svg.selectAll('.node')
          .on('mouseover', function(event, d) {
            let matchId = d3.select(this).attr('id');
            if(!matchId) return;

            let data = null;
            // Iterate and find matching key from our nodeData map
            for (let key in nodeData) {
              if (matchId.includes(key)) {
                data = nodeData[key];
                break;
              }
            }

            if (data) {
              tooltip.style("display", "block")
                .html(`<h4>Dirigente: ${data.dirigente || 'Não informado'}</h4><p>Ano de Fundação: ${data.ano || 'N/A'}</p>`);
            }
          })
          .on('mousemove', function(event) {
            const containerRect = document.getElementById('tree-container').getBoundingClientRect();
            let left = event.clientX - containerRect.left + 15;
            let top = event.clientY - containerRect.top + 15;
            
            if (left + 300 > containerRect.width) {
              left = event.clientX - containerRect.left - 315;
            }
            
            tooltip.style("left", left + "px")
                   .style("top", top + "px");
          })
          .on('mouseout', function() {
            tooltip.style("display", "none");
          });
          
          // Estiliza cursor para indicar interatividade
          svg.selectAll('.node')
             .style('cursor', 'pointer');
      }
    }, 300); // Check every 300ms
  });
</script>
