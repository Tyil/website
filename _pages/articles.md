---
layout: default
permalink: /articles/
---

## Articles
I sometimes write articles to refer to. It saves a lot of time compared to
explaining the same thing over and over again. As such, most articles will
probably be little rants. All of the articles I wrote have been made public on
my site, and can be found below, in alphabetical order.

{% for article in site.articles %}
{% if article.wip %}
	{% continue %}
{% endif %}
* [{{ article.title }}]({{ article.url }})
{% endfor %}

If you wish to respond to any article, whether it be criticism, reporting
mistakes or simply because you want to discuss the points, feel free to send me
an email. My email address is listed [on the homepage][home]. If you do,
consider adding a PGP signature or sending it encrypted with [my pgp key][pgp].

[home]: /
[pgp]: http://pgp.mit.edu/pks/lookup?op=vindex&search=0x9ACFE193FFBC1F50
