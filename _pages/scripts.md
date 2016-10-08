---
layout: default
permalink: /scripts.html
---

## Scripts
These are some small scripts which I share in the hope that they may help out
other people in the future. Since these are just simple scripts, it is not
really worth it to classify them as a full project.

{% for script in site.scripts %}
* [{{ script.title }}]({{ script.url }})
{% endfor %}

### License
All scripts published here are released under the GNU GPL version 3 or later.
