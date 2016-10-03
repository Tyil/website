---
layout: default
permalink: /posts.html
---

## Posts
I sometimes write posts to have an article to refer to. It saves a lot of time
compared to explaining the same thing over and over again. As such, most posts
will probably be little rants.

{% for post in site.posts %}
* [{{ post.title }}]({{ post.url }}) {% if post.wip %} (**Work in progress**) {% endif %}
{% endfor %}
