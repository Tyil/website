---
title: "Perl6: Using `App::Assixt` to improve module development"
theme: github
---

# `App::Assixt`
## Improving module development

---

# About me

- Patrick Spek (`TYIL`)
- https://tyil.nl
- @tyil@mastodon.social

note:
	I have about 10 Perl 6 modules available on CPAN right now. `Config` and
	parser modules, `IRC::Client` plugins, `Hash::Merge`, `Dist::Helper` and
	`App::Assixt`.

---

# Why?

- Manually updating JSON is annoying
- Wanted to ease development

note:
	It's my 2nd project in Perl 6, following `Config`.

---

# How?

- Uses `Dist::Helper`
- Updates `META6.json`
- Creates skeleton files

note:
	`Dist::Helper` is the base that deals with the actual interaction with the
	modules. `App::Assixt` is a CLI frontend with some nice extras to make it
	usable.

---

# How do I get it?

```
$ zef install App::Assixt
```

note:
	`App::Assixt` is easily available through `CPAN`, and `zef` is able to
	install it cleanly nowadays.

---

# Using it

```
$ assixt help
```

---

# Adding files

## Manual
```
$ mkdir -p lib/App/Local
$ touch lib/App/Local/NewClass.pm6
$ $EDITOR META6.json
```

## `assixt`
```
$ assixt touch class App::Local::NewClass
```

- Classes
- Tests
- Unit modules

---

# Adding a dependency

## Manual
```
$ $EDITOR META6.json
$ zef install Config
```

## `assixt`
```
$ assixt depend Config
```

note:
	`--no-install` skips the step where `zef` tries to install the module.

---

# Bumping the version

## Manual
```
$ $EDITOR META6.json
```

## `assixt`
```
$ assixt bump
```

note:
	`bump` asks for additional user input to decide whether to bump the patch,
	minor or major level.

---

# Create a new dist

## Manual
```
$ tar czf My-Dist-0.1.2.tar.gz --exclude-vcs-ignores [--exclude...] .
$ mv !:2 ~/.local/dists/.
```

## `assixt`
```
$ assixt dist
```

---

# Uploading to CPAN

## Manual
Through your favourite webbrowser

## `assixt`
```
$ assixt upload ~/.local/var/assixt/dists/Dist-Helper-0.19.0.tar.gz
```

---

# `push` shorthand

```
$ assixt push
```

- Bump
- Dist
- Upload

note:
	Does a `bump`, `dist` and `upload`, one after another.

---

# Workflow

```
$ assixt new Local::App
$ cd perl6-local-app
$ assixt depend Config
$ assixt touch class Local::App::Foo
$ assixt push
```

note:
	Creates a new module directory, make the module depend on `Config`, create a
	class named `Local::App::Foo` and push the module to CPAN.

---

# Future plans

---

## QA check
- Will perform QA checks to improve module quality
- Based on `Release::Checklist` by [Tux]
- Work In Progress on Github

---

## Other ideas
- `meta`: To update misc dist info, such as the authors
- `sync-meta`: To synchronize a `META6.json` from an existing module
- Improve `new`: Also generate a default `README.pod6`

note:
	`sync-meta` is intended to also create a new `META6.json` if none exists
	yet.

---

# Questions
