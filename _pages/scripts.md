---
layout: default
permalink: /scripts/
title: Script index
---

## Scripts
These are some small scripts which I share in the hope that they may help out
other people in the future. Since these are just simple scripts, it is not
really worth it to classify them as a full project. Scripts are only a single
file that serve only a single purpose, and most often written in
POSIX-compatible shell, because this is the most portable language to work in.

I have used or am still using these scripts for my personal use, but there's no
guarantee that these will work for you without any changes. If you have issues
and cannot seem to figure out what's going wrong, feel free to seek me out on
IRC. You can find my IRC details [on the hompage][home].

{% for script in site.scripts %}
* [{{ script.title }}]({{ script.url }})
{% endfor %}

This is most certainly not a definitive list, and I don't try to make it one
either, as that would be way too much work. However, I do keep my configuration
files (or dotfiles) in a public git repository. You can find this repository
[on Github][dotfiles]. There's a directory in there called [`scripts`][scripts]
that has the entire collection of scripts that I actively use.

### License
All scripts published here are released under the GNU GPL version 3 or later,
unless stated otherwise.

[dotfiles]: https://github.com/tyil/dotfiles
[home]: /
[scripts]: https://github.com/Tyil/dotfiles/tree/master/shell/scripts
