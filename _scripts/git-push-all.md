---
layout: default
title: Git push all
lang: shell
---

This script should be saved as `git-push-all` somewhere in your `$PATH`. You
can then run `git push-all` to push to all remotes for repo. The script itself
is written with the POSIX compatible shell in mind, and should work on every
POSIX compatible distro (this is nearly every distro ever).

I wrote this script to keep multiple remotes in sync, for instance a repository
that is hosted on both [Github][github] and [Gitlab][gitlab]. It's a tedious
task to manually push everything twice, so a shell script was born.

If no branch is given to push, it will attempt to push the `master` branch. The
list of remotes to push to is retrieved from the repo itself, through the
output of `git remote`.

{% highlight sh linenos %}
#! /usr/bin/env sh

main()
{
	branch="master"

	if [ -n "$1" ]
	then
		branch="$1"
		shift
	fi

	for remote in $(git remote)
	do
		echo "Pushing to ${remote}:${branch}..."
		git push "${remote}" "${branch}" "$@"
	done
}

main "$@"
{% endhighlight %}

[github]: https://github.com/
[gitlab]: https://about.gitlab.com/
