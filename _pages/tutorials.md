---
layout: default
permalink: /tutorials/
title: Tutorials
---

## Tutorials
These are mostly inspired by questions I see repeated often in help channels on
IRC, or from people I see at tech meetups. Since it's often easier to give them
a link than give each person a hands-on training every time, I have written
these tutorials.

Some are written out of notes I kept for myself when learning how to setup a
certain environment. These notes then get extended, and written into a tutorial
that is easy to follow (I hope, at least).

Sadly, times change, and things change with it. In effect, tutorials may get
outdated. I can't keep track of all changes that happen, so I can't keep all
tutorials up to date. If you find anything that is no longer correct, do notify
me via any channel you find most convenient. You can find details for these [on
the homepage][home]. You can also contact me for any other kind of feedback, of
course.

{% for tutorial in site.tutorials %}
{% if tutorial.wip %}
	{% continue %}
{% endif %}
* [{{ tutorial.title }}]({{ tutorial.url }})
{% endfor %}

[home]: /
