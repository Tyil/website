---
layout: default
title: MyAnimeList to Jekyll
lang: python 3
---

This script is intended to be used for migrating from MyAnimeList to your own
Jekyll based site. Export your anime list there, and adapt the script to point
to the right directory.

{% highlight py %}
#!/usr/bin/env python3

import re
import xml.etree.ElementTree as ElementTree


def main():
    # update the paths here
    xml_path = "/home/tyil/downloads/palemoon/animelist.xml"
    out_dir = "/home/tyil/projects/private/jekyll/tyil/_anime/"

    # open the xml file
    tree = ElementTree.parse(xml_path)
    root = tree.getroot()

    for anime in root:
        # skip your info
        if anime.tag == "myinfo":
            continue

        # clean up the file name
        f = re.sub("[?!:☆♪.,/]", "", anime.find("series_title").text)
        f = f.lower()
        f = f.replace(" ", "-")
        f = re.sub("-+", "-", f)

        # open the stream and write the front matter to it
        s = open(out_dir + f + ".md", "w")
        s.write("---\n")
        s.write("title: \"%s\"\n" % anime.find("series_title").text)
        s.write("episodes: %s\n" % anime.find("series_episodes").text)

        status = anime.find("my_status").text

        if status == "Plan to Watch":
            s.write("status: planned\n")

        if status == "Watching":
            s.write("status: watching\n")
            s.write("progression: %s\n" % anime.find("my_watched_episodes").text)

        if status == "Completed":
            s.write("status: completed\n")
            s.write("rating: %s\n" % anime.find("my_score").text)

        s.write("---\n")
        s.close()

if __name__ == '__main__':
    main()
{% endhighlight %}

