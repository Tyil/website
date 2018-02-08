---
layout: default
title: install-perl6.sh
lang: shell
---

This is a small shellscript to download Rakudo Perl 6, build it, install it
into `~/.local` and clean up the sources again. Once completed, this will result
in Perl 6 being installed in your `~/.local` directory.

To make good use of it, you will have to add the following two paths to your
`$PATH`:

- `~/.local/bin` (for `perl6`)
- `~/.local/share/perl6/site/bin` (for executables from installed modules)

{% highlight sh linenos %}
#! /usr/bin/env sh

readonly WORKDIR="$HOME/.local/src/perl6"

build()
{
	perl Configure.pl --gen-moar --gen-nqp --backends=moar --prefix=$HOME/.local
	make
	make install
}

cleanup()
{
	cd || exit
	rm -rf "$WORKDIR"
}

prepare()
{
	git clone https://github.com/rakudo/rakudo/ "$WORKDIR"
	cd "$WORKDIR" || exit

	git checkout "$1"
	git pull
}

main()
{
	prepare "${1:-master}"
	build
	perl6 --version
	cleanup
}

main "$@"
{% endhighlight %}
