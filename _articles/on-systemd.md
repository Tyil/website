---
layout: post
title:  On Systemd
date:   2016-10-01 10:20:27 +0200
tags:   Harmful Systemd
authors:
  - ["Patrick Spek", "http://tyil.work"]
  - ["Samantha McVey", "https://cry.nu"]
---

# Systemd
Systemd once presented itself as being the next generation init system for
GNU+Linux. When the project started it seemed to be headed in a good direction.
Unfortunately, it quickly became clear that systemd's goal was not only to
bring you a quick, new init system.  It planned to do so much more.  This was
part of the plan, since init systems were generally considered to be in a bad
state overall it was quickly accepted by most mainstream GNU+Linux
distributions.  What was at first only an init system became so much more:
systemd-logind was made to manage tty's, systemd-resolvd was added to act as a
caching DNS server.  Even networking was added with systemd-networkd to manage
network interfaces.

**DISCLAIMER**: Systemd is a fast moving project, this may result in
information here to becoming outdated. If you find any information that is no
longer correct, please contact me. You can find my contact details [on my
homepage][tyil].

## Technical issues
### Security
From experience, we have seen that systemd's creator, Lennart Poettering, will
try to assimilate any functionality he can find and add it into systemd.  This
causes systemd to have a large surface area of attack, adding to and magnifying
security attack vectors. An init system should be exactly the opposite. To
compound this issue, we have bugs like [the user-level DoS][systemd-dos],
which seem to indicate that the software is hardly tested or written by
programmers who don't use best practices.

### POSIX
POSIX compliance. Systemd developers seem to detest it. Their common argument
against retaining POSIX compliance is that "systemd must break POSIX compliance
in order to further the development of GNU+Linux userland utilities". While
this may be true in some sense, it is a very bad idea to ignore POSIX
altogether.

POSIX is one of the reasons that most applications running on GNU+Linux and
other Unix like systems are very portable. It's a standard that most OS's and
distro's try to meet, making it easy to port software.

[natermeer on Reddit][reddit-natermeer] said
> POSIX has almost no relevance anymore.
>
> [...]
>
> If you care about portability you care about it running on OS X and Windows
> as well as your favorite \*nix system. POSIX gains you nothing here. A lot
> of the APIs from many of these systems will resemble POSIX closely, but if
> you don't take system-specific differences into account you are not going
> to accomplish much.

> I really doubt that any Init system from any Unix system uses only POSIX
> interfaces, except maybe NetBSD. All of them are going to use scripts and
> services that are going to be running commands that use kernel-specific
> features at some point. Maybe a init will compile and can be executed on
> pure POSIX api, but that is a FAR FAR cry from actually having a booted and
> running system.

Which was replied to by [aidanjt][reddit-aidanjt]
> Wrong, both OS X and Windows have POSIX support, although Window's is emulated,
> OS X certainly is not, it's fully POSIX compliant. and b) POSIX doesn't have to
> work identically everywhere, it only has to be more or less the same in most
> places and downstream can easily patch around OS-specific quirks. Even
> GNU/Linux and a bunch of the BSDs are merely regarded as 'mostly' POSIX
> compliant, after all. But if you ignore POSIX entirely, there's ZERO hope of
> portability.
>
> Actually sysvinit is very portable, init.c only has 1 single Linux header which
> has been #ifdef'ed, to handle the three-finger-salute. You see, init really
> isn't that complicated a programme, you tell the kernel to load it after it's
> done it's thing, init starts, and loads distro scripts which starts userspace
> programmes to carry on booting. No special voodoo magic is really required.
> POSIX is to thank for that. POSIX doesn't need to be the only library eva, it
> only needs to handle most of the things you can't do without, without having to
> directly poke at kernel-specific interfaces.
>
> This is why with POSIX, we can take a piece of software written for a PPC AIX
> mainframe, and make it work on x86 Linux without a complete rewrite, usually
> with only trivial changes.

### Dependencies and unportability
Another common issue with systemd is that applications have started to
needlessly depend on it, forcing systemd onto users that do not wish to use
systemd for obvious reasons outlined here, reasons outside of this article, or
simply being unable to use it. Because systemd complies to no cross-platform
standard and uses many features only available in recent Linux version, it's
either very hard or impossible to implement systemd in some circumstances.

The list of features it requires is no small one either, as you can see in the
list [posted by ohset][reddit-ohet]:

- `/dev/char`
- `/dev/disk/by-label`
- `/dev/disk/by-uuid`
- `/dev/random`
- `/dev/rtc`
- `/dev/tty0`
- `/proc/$PID/cgroup`
- `/proc/${PID}/cmdline`
- `/proc/${PID}/comm`
- `/proc/${PID}/fd`
- `/proc/${PID}/root`
- `/proc/${PID}/stat`
- `/proc/cmdline`
- `/sys/class/dmi/id`
- `/sys/class/tty/console/active`
- `BTRFS_IOC_DEFRAG`
- `CLONE_xxx`
- `F_SETPIPE_SZ`
- `IP_TRANSPORT`
- `KDSKBMODE`
- `O_CLOEXEC`
- `PR_CAPBSET_DROP`
- `PR_GET_SECUREBITS`
- `PR_SET_NAME`
- `PR_SET_PDEATHSIG`
- `RLIMIT_RTPRIO`
- `RLIMIT_RTTIME`
- `SCHED_RESET_ON_FORK`
- `SOCK_CLOEXEC`
- `TIOCLINUX`
- `TIOCNXCL`
- `TIOCVHANGUP`
- `VT_ACTIVATE`
- `\033[3J`
- `audit`
- `autofs4`
- `capabilities`
- `cgroups`
- `fanotify`
- `inotify`
- `ionice`
- `namespaces`
- `oom score adjust`
- `openat()` and friends
- `selinux`
- `settimeofday()` and its semantics
- `udev`
- `waitid()`
- numerous GNU APIs like `asprintf`

This made [Gnome][gnome] unavailable for a long time to BSD users and GNU+Linux
users who wanted to remain with a sane and proven system. Utilities like
[Gummiboot][gummiboot] are now being absorbed by systemd too. It is only a
matter of time before you can no longer use this utility without a systemd init
behind it. There are too many examples of software to list, which are being
assimilated or made unavailable by lazy or bad developers who choose to depend
on systemd for whatever reason.

### Speed
The main selling point many systemd users hail all the time, is speed. They
place an unusual high amount of value on being a couple seconds faster on boot.
Systemd gains this speed gain by using parallelization, and many think this is
unique to systemd. Luckily for those who want to stick to a more sane system,
this is false. Other init systems, such as [OpenRC][openrc], used by
[Funtoo][funtoo], and [runit][runit], used by [Voidlinux][voidlinux] both
support parallel startup of services.  Both these systems use small and
effective shell scripts for this, and support startup dependencies and the
like. Systemd brings nothing new to the init world, it just advertises these
features more agressively.

### Modularity
The UNIX principle, *make an application perform one task very well*, seems to
be very unpopular among systemd developers. This principle is one of the
reasons why UNIX based systems have gotten so popular. Yet, the systemd
developers seem to despise this principle, and even try to argue that systemd
actually is modular because **it compiles down to multiple binaries**. This
shows a lack of understanding, which would make most users uneasy when they
consider that these people are working on one of the most critical pieces of
their OS.

The technical problem this brings is that it is very hard to use systemd with
existing tools. `journald` for instance doesn't just output plain text you can
easily filter through, save or apply to a pager. I decides for you how to
represent this information, even if this might be an ineffective way to go
about it.

### Binary logs
Hailed by systemd users and developers as a more efficient, fast and secure way
to store your logs, it is yet another middle finger to the UNIX principles,
which state that documents intended for the user should be human readable.
Binary logs are exactly not that. This forces you to use the tools bundled with
systemd, instead of your preferred solution. This means you need a system with
systemd in order to read your logs, which you generally need the most when the
system that generated it crashed. Thanks to systemd, these logs are now useless
unless you have another systemd available for it.

These logs are also very fragile. It is a common "issue" to have corrupted logs
when using systemd. Corrupted is here within quotes because the systemd
developers do not recognize this as a bug. Instead, you should just rotate your
logs and hope it does not happen again.

The usual counter to this issue is that you *can* tell systemd to use another
logger. However, this does not stop `journald` from processing them first or
just not having `journald` at all. As systemd is not modular, you will always
have all the pieces installed. It should also be noted that this is a
*workaround*, not a fix to the underlying problem.

## Political issues
### Aggressively forced upon users
A point that has made many systemd opponents very wary of this huge piece of
software is the way it was introduced. Unlike most free software packages,
systemd was forced into the lives of many users by getting hard dependencies on
them, or simply absorbing a critical piece of software by the use of political
power. The two most prominent pieces of software where this has happened are
[Gnome][gnome] and [`udev`][udev].

The Gnome developers made a hard dependency on systemd. This in effect made
every gnome user suddenly require systemd. As a result, FreeBSD had to actually
drop Gnome for a while, as systemd does not run outside of GNU+Linux.

The other, `udev`, was a critical piece of software to manage devices in
GNU+Linux. Sadly, some political power was shown by Red Hat and `udev` got
absorbed into systemd. Luckily, the Gentoo guys saw this issue and tried to
resolve it. As the systemd developers dislike anything that's not systemd
itself, they stubbornly refused the patches from the Gentoo folks which would
keep `udev` a single component (and thus usable without systemd). In the end,
the Gentoo developers forked `udev` into [`eudev`][eudev].

### Unwillingness to cooperate
Whenever someone from outside the systemd fangroups steps up to actually
improve systemd in whatever way, the systemd devs seem to be rather
uncooperative. It is not uncommon for developers from other projects to make a
change in order for their projects (and usually others) to improve. This
removes a lot of the cost for the systemd maintainers to deal with all the
issues created they are creating.

There are some references to the systemd developers being against changes that
might make systemd less of a problem, but these changes are usually denied with
petty excuses.

- https://lists.freedesktop.org/archives/systemd-devel/2012-June/005466.html
- https://lists.freedesktop.org/archives/systemd-devel/2012-June/005507.html

## How to avoid it
### Choosing a better OS or distribution
Nowadays, the only way to avoid it without too much trouble, is by simply
choosing a better OS or distro that does not depend on systemd at all. There
are a few choices for this:

- \*BSD ([FreeBSD][freebsd], [OpenBSD][openbsd], and others)
- [Devuan][devuan]
- [Funtoo][funtoo]
- [Voidlinux][voidlinux]

It is a shame that it renders a very large chunk of the GNU+Linux world
unavailable when choosing a distro, but they have chosen laziness over a
working system. The only way to tell them at this point that they have made a
wrong decision, is to simply stop using these distros.

### More links

- [Broken by design: systemd][broken-systemd]
- [Without systemd][without-systemd]
- [systemd is the best example of Suck][suckless-systemd]
- [Thoughts on the systemd root exploit][agwa-systemd-root-exploit] (In response to [CVE-2016-10156][cve-2016-10156])
- ["systemd: Please, No, Not Like This"](https://fromthecodefront.blogspot.nl/2017/10/systemd-no.html)

[agwa-systemd-root-exploit]: https://www.agwa.name/blog/post/thoughts_on_the_systemd_root_exploit
[broken-systemd]: http://ewontfix.com/14/
[cve-2016-10156]: http://www.openwall.com/lists/oss-security/2017/01/24/4
[devuan]: https://devuan.org/
[eudev]: https://wiki.gentoo.org/wiki/Eudev
[freebsd]: https://www.freebsd.org/
[funtoo]: http://www.funtoo.org/Welcome
[gentoo]: https://gentoo.org
[gnome]: http://www.gnome.org/
[gummiboot]: https://en.wikipedia.org/wiki/Gummiboot_(software)
[openbsd]: https://www.openbsd.org/
[openrc]: https://en.wikipedia.org/wiki/OpenRC
[reddit-aidanjt]: https://www.reddit.com/r/linux/comments/132gle/eli5_the_systemd_vs_initupstart_controversy/c72saay
[reddit-natermeer]: https://www.reddit.com/r/linux/comments/132gle/eli5_the_systemd_vs_initupstart_controversy/c70hrsq
[reddit-ohet]: https://www.reddit.com/r/linux/comments/132gle/eli5_the_systemd_vs_initupstart_controversy/c70cao2
[runit]: http://smarden.org/runit/
[suckless-systemd]: http://suckless.org/sucks/systemd
[systemd-dos]: https://github.com/systemd/systemd/blob/b8fafaf4a1cffd02389d61ed92ca7acb1b8c739c/src/core/manager.c#L1666
[tyil]: http://tyil.work
[udev]: https://en.wikipedia.org/wiki/Udev
[voidlinux]: http://www.voidlinux.eu/
[without-systemd]: http://without-systemd.org/wiki/index.php/Main_Page
