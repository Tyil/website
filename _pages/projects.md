---
layout: default
permalink: /projects/
title: Software projects
---

# Projects
Here is a list of all projects I worked on that I deem good or important enough
to publish here. This list won't always be complete, but you can check [my
Github profile][github] if you're interested to see more.

All of the projects listed below are [Free software][free-software], and are
made in my free time. Contributions in any form are welcome. This includes, but
is not limited to, pull/merge requests, bug reports are [financial
support][support]. You can also come discuss the projects and possible issues
you have found with them on IRC or contact me through email. Details for both
can be found [on the homepage][home].

<table class="table">
	<thead>
		<tr>
			<th>Project</th>
			<th>Language(s)</th>
			<th>License</th>
			<th>Repository</th>
		</tr>
	</thead>
	<tbody>
		{% for project in site.projects %}
			<tr>
				<td>{{ project.title }}</td>
				<td>{{ project.langs }}</td>
				<td>{{ project.license }}</td>
				<td><a href="{{ project.repo }}">{{ project.repo }}</a></td>
			</tr>
		{% endfor %}
	</tbody>
</table>

[free-software]: https://en.wikipedia.org/wiki/Free_software
[github]: https://github.com/tyil
[home]: /
[support]: /support/
