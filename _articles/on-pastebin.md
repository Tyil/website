---
layout: post
title:  On Pastebin
date:   2016-10-01 10:20:27 +0200
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# Pastebin
Pastebin offers itself as a gratis paste service. Although it is probably the
most well known option out there, it is certainly not the best.

## The security issue
Pastebin has a couple of issues that harm the visitor's security. This on
itself should be considered such a bad practice that no-one should consider
their service at all.

### Cloudflare
Cloudflare is a [MITM][mitm]. It completely breaks the secure chain of TLS on
the web, and should not be used. Any service still using Cloudflare should be
shunned.  There is [another article][cloudflare] on this site which has more
information on this specific issue. In addition, Cloudflare can be considered a
privacy issue for the same reasons, as is detailed below.

### Advertisements
Another issue with regards to security on pastebin are the advertisements.
While it can be argued that "they need to make money somehow", using ads always
seems like the worst possible solution. Especially given the way they're
serving it. The past couple years have shown that advertisements on the web are
easily abused to serve malware to good netizens who decided to not block all
ads.

A rant on the state of ads might be appropriate, but this article is
specifically about Pastebin, so I will just keep it at "third party
advertisements are a security risk, avoid sites who use them"

## The privacy issue
Apart from their security issues, Pastebin also offers some privacy issues. As
stated above, they make use of Cloudflare. This means that whenever you visit
them, Cloudflare takes note of this. They may even decide that you need to
perform some additional tasks in order to be allowed to the resource. This
doesn't happen to most users, but if you're using any anonymization practices,
this will happen almost every time you visit a site behind Cloudflare.

In addition to telling Cloudflare, you will also tell another third party,
Google, in case this "additional step" is required. This is done via the new
reCaptcha system which will inform Google of almost every detail of your
browser and the behaviour used to solve the puzzle. Incredibly useful for
fingerprinting you accross multiple locations.

### Then there is Tor
But, if you're using an anonymization proxy such as Tor, even if you do not
care about the Cloudflare issue, and you solve the "security check" presented
to you, Pastebin still refuses to offer you their service. If they are going to
refuse you service, they should tell you up front, not after you have already
informed two other harmful parties of your attempt of accessing the resource.

Actually, they should not. They should simply not require you to give up your
privacy and serve you the content you were looking for. Blocking resources to a
certain group of users is simply censorship, and should not be the status quo
on the free internet.

## Alternatives
Luckily, there are plenty of alternatives that do not treat their users with
such disrespect. I ask anyone who is still using Pastebin to stop doing this,
and use any of the alternatives.

* [0bin.net](https://0bin.net/)
* [cry.nu][crynu] (works like termbin: `nc cry.nu 9999 < file`)
* [ix.io][ix]
- [p.tyil.nl][tyilnl] (worsk like termbin: `nc p.tyil.nl 9999 < file`)

[cloudflare]: /articles/on-cloudflare.html
[crynu]: https://cry.nu
[hastebin]: http://hastebin.com
[ix]: http://ix.io/
[mitm]: https://en.wikipedia.org/wiki/Man-in-the-middle_attack
[termbin]: http://termbin.com
[tyilnl]: https://tyil.nl
