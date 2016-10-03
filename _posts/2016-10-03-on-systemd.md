---
layout: post
title:  On Systemd
date:   2016-10-01 10:20:27 +0200
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# Systemd
Systemd once presnted itself as being the next generation init system for
GNU+Linux. The idea of it was looking good. Sadly, it quickly became clear that
systemd was not trying to bring you just a new, quick init system. That was
just a part of the plan, an easy target to aim for as the init systems are
generally considered to be in a bad state overal.

**DISCLAIMER**: Systemd is a fast moving target to document anything against.
This may result in information here to become outdated. If you find any
information that is no longer correct, please contact me. You can find my
contact details [on my homepage][tyil].

## Security
Now we have seen that Poettering will try to assimilate anything he can find
and put it into systemd, making it a huge platform with an even bigger attack
vector. An init system should be exactly the opposite. The problem is made even
worse with bugs like [the user-level DDoS][systemd-ddos], which seem to
indicate that the software is hardly tested or written by programmers who use
best practices.

## POSIX
Another thing that systemd developers seem to detest, is POSIX compliance. A
common argument against it is that "systemd must break posix compliance in
order to further the development of GNU+Linux userland utilities". While this
could be true in some sense, it sounds like a very bad idea to just ignore
POSIX altogether.

POSIX is one of the reasons that most applications are very portable. It's a
standard that most OSs and distros try to hold true, just so it becomes easy to
port over software.

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
needleslly depend on it, forcing systemd onto users that do not with to use
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

## Speed
> paralellization

## Ease of use
> everything into 1 package

## Aggressively forced upon users

## Unwillingness to cooperate
> https://lists.freedesktop.org/archives/systemd-devel/2012-June/005466.html
> http://lists.freedesktop.org/archives/systemd-devel/2012-June/005507.html

[reddit-aidanjt]: https://www.reddit.com/r/linux/comments/132gle/eli5_the_systemd_vs_initupstart_controversy/c72saay
[reddit-natermeer]: https://www.reddit.com/r/linux/comments/132gle/eli5_the_systemd_vs_initupstart_controversy/c70hrsq
[reddit-ohet]: https://www.reddit.com/r/linux/comments/132gle/eli5_the_systemd_vs_initupstart_controversy/c70cao2
[systemd-ddos]: https://github.com/systemd/systemd/blob/b8fafaf4a1cffd02389d61ed92ca7acb1b8c739c/src/core/manager.c#L1666
[tyil]: http://tyil.work
[gnome]: http://www.gnome.org/
[gummiboot]: https://en.wikipedia.org/wiki/Gummiboot_(software)

