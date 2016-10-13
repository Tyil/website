---
layout: default
title: Git push all
lang: shell
---

This script should be saved as `git-push-all` somewhere in your `$PATH`. You
can then run `git push-all` to push to all remotes for repo.

```
#!/usr/bin/env sh

main()
{
	branch="master"

	if test -n "$1"
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
```

