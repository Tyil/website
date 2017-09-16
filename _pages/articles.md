---
layout: default
permalink: /articles.html
---

## Articles
I sometimes write articles to refer to. It saves a lot of time compared to
explaining the same thing over and over again. As such, most articles will
probably be little rants.

{% for article in site.articles %}
{% if article.wip %}
	{% continue %}
{% endif %}
* [{{ article.title }}]({{ article.url }})
{% endfor %}
