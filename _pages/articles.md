---
layout: default
permalink: /articles.html
---

## Article
I sometimes write articles to refer to. It saves a lot of time compared to
explaining the same thing over and over again. As such, most articles will
probably be little rants.

{% for article in site.articles %}
* [{{ article.title }}]({{ article.url }}) {% if article.wip %} (**Work in progress**) {% endif %}
{% endfor %}
