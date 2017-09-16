---
layout: default
permalink: /tutorials.html
---

## Tutorials
This is a list of tutorials I wrote.

{% for tutorial in site.tutorials %}
{% if tutorial.wip %}
	{% continue %}
{% endif %}
* [{{ tutorial.title }}]({{ tutorial.url }})
{% endfor %}
