---
layout: default
permalink: /projects.html
---

## Projects
Here is a list of all projects I worked on that I deem good or important enough
to publish here.

<table>
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
