---
layout: default
permalink: /anime.html
---

## My anime list
Here's a list of all the anime I have watched or am planning to watch. This
mostly exists for me to keep track of how far I am with the series I am
watching, and to have a nice list of series I still want to watch.

### Watching
<table class="table">
	<thead>
		<tr>
			<th>Series</th>
			<th>Episodes</th>
		</tr>
	</thead>
	<tbody>
		{% for series in site.anime %}
			{% if series.status != "watching" %}
				{% continue %}
			{% endif %}
			<tr>
				<td>{{ series.title }}</td>
				<td>
					{{ series.progress }} / {{ series.episodes }}
				</td>
			</tr>
		{% endfor %}
	</tbody>
</table>

### Completed
<table class="table">
	<thead>
		<tr>
			<th>Series</th>
			<th>Rating</th>
			<th>Episodes</th>
		</tr>
	</thead>
	<tbody>
		{% for series in site.anime %}
			{% if series.status != "completed" %}
				{% continue %}
			{% endif %}
			<tr>
				<td>{{ series.title }}</td>
				<td>{{ series.rating }}</td>
				<td>{{ series.episodes }}</td>
			</tr>
		{% endfor %}
	</tbody>
</table>

### Plan to watch
<table class="table">
	<thead>
		<tr>
			<th>Series</th>
			<th>Season</th>
		</tr>
	</thead>
	<tbody>
		{% for series in site.anime %}
			{% if series.status != "planned" %}
				{% continue %}
			{% endif %}
			<tr>
				<td>{{ series.title }}</td>
				<td>{{ series.season }}</td>
			</tr>
		{% endfor %}
	</tbody>
</table>
