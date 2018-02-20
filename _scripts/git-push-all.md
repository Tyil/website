---
layout: default
title: Git push all
lang: shell
---
I wrote this script to keep multiple remotes in sync, for instance a repository
that is hosted on both [Github][github] and [Gitlab][gitlab]. It's a tedious
task to manually push everything twice, so a shell script was born.

The script should be saved as `git-push-all`, somewhere in your `$PATH`. You
can then run `git push-all` to push to all remotes defined for the current
repo. The script itself is written with the POSIX compatible shell in mind, and
should work on every POSIX compatible distro (this is nearly every distro
ever) and OS (such as FreeBSD).

If no branch is given to push, it will attempt to push the `master` branch. The
list of remotes to push to is retrieved from the repo itself, through the
output of `git remote`.

The itself script is rather straightforward, but if you have any questions or
suggestions, do not hesitate to reach out to me. Contact details are available
[on the homepage][home]. As always, feedback is greatly appreciated, as it
helps me write better POSIX shell scripts. Or it could help me explain and
teach others better.

{% highlight sh linenos %}
#! /usr/bin/env sh

main()
{
	branch=${1:-master}
	shift

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
[home]: /
