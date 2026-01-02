---
layout: page
title: Arquivo Completo
permalink: /arquivo/
---
## Todos os Posts (Lista de Verificação)
| Data | Título |
|:--- |:--- |
{% for post in site.posts %}
| {{ post.date | date: "%d/%m/%Y" }} | [{{ post.title }}]({{ post.url }}) |
{% endfor %}
