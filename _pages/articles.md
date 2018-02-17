---
layout: default
permalink: /articles/
title: Articles
---

## Articles
I sometimes write articles to refer to. It saves a lot of time compared to
explaining the same thing over and over again. As such, most articles will
probably be little rants. All of the articles I wrote have been made public on
my site, and can be found below, in alphabetical order.

If you wish to respond to any article, whether it be criticism, reporting
mistakes or simply because you want to discuss the points, feel free to send me
an email. My email address is listed [on the homepage][home]. If you do,
consider adding a PGP signature or sending it encrypted with [my pgp key][pgp].
All feedback is greatly appreciated, so do not hesitate to contact me to give
me yours.

These articles are available under the [Creative Commons (CC BY-SA
3.0)][cc-by-sa] license, which means you are free to use it for any purpose so
long as you keep attribution to me (and preferably also just link to the
original article) and do not relicense the article.

I'd also like to note that these articles reflect my opinion, and only mine.
Please refrain from accusing other people of holding my opinion for simply
being referenced in my articles.

{% for article in site.articles %}
{% if article.wip %}
	{% continue %}
{% endif %}
* [{{ article.title }}]({{ article.url }})
{% endfor %}

[cc-by-sa]: https://creativecommons.org/licenses/by-sa/3.0/
[home]: /
[pgp]: http://pgp.mit.edu/pks/lookup?op=vindex&search=0x9ACFE193FFBC1F50
