---
layout: post
title:  On Cloudflare
date:   2016-09-30 08:25:27 +0200
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# Cloudflare
Cloudflare is a threat to online security and privacy. I am not the first on to
address this issue, and I probably will not be the last either. Sadly, people
still seem to be very uninformed as to what issues Cloudflare actually poses.
There also seems to be a big misconception about the benefits provided by using
Cloudflare. I would suggest reading the [article on Cloudflare by
joepie91][joepie] for a more thorough look at Cloudflare.

If anyone is using Cloudflare, please tell them to stop doing it. Link them to
this page or any of the articles referenced here. Cloudflare is harmful to your
visitors, and if you do not care about them, they will stop caring about you
too.

## A literal MITM attack
Cloudflare poses a huge risk by completely breaking the TLS/SSL chain used by
browsers by setting itself up as [man in the middle][mitm]. Cloudflare doesn't
do actual DDoS protection, they just make the request to the origin server for
you. Once they have received the data, they decrypt it and re-encrypts it
with their own certificate.  This means that Cloudflare has access to all
requests in plaintext and can optionally modify the data you see. TLS/SSL
is ment to prevent this very issue, but Cloudflare seems to care very
little.

If we would consider Cloudflare to be a benevolent entity and surely never
modify any data ever, this is still an issue. Much data can be mined from the
plaintext communications between you and the origin server. This data can be
used for all kinds of purposes. It is not uncommon for the USA government to
request a massive amount of surveillance information from companies without the
companies being able to speak up about it due to a gag order. This has become
clear once more by the [subpoena on Signal][signal-subpoena]. It should be
clear to anyone that end-to-end encryption has to be a standard and implemented
properly. Cloudflare goes out of its way to break this implementation.

## Eliminating your privacy
If Cloudflare were to fix their MITM behaviour, the privacy problem would not
be solved all of a sudden. There are more questionable practices in use by
Cloudflare.

People who are using a VPN or an anonimization service such as Tor are usually
greeted by a warning from Cloudflare. Let's not talk about this warning being
incorrect about the reason behind the user receiving the warning, but instead
about the methodology used to "pass" this "warning". Cloudflare presents you
with a page that requires you to solve a reCaptcha puzzle, which is hosted by a
well known third party that tries to harm your privacy as much as possible,
Google. If you do not wish to have Google tracking you all the time, you will
not be able to solve these puzzles, and in effect, unable to access the site
you were visiting. It is also interesting to note that this reCaptcha system is
sometimes broken if your browser does not identify itself as one of the regular
mainstream browsers such as Firefox or Chrome.

Some site administrators disable this specific check. However, this still means
all your requests are logged by another third party, namely Cloudflare itself.
As noted in **A literal MITM attack**, this data is still very interesting to
some parties. And do not fool yourself: metadata is still very worthwhile and
can tell a huge amount of information about a person.

## Forcing JavaScript
This issue generally does not concern many people, as most people online
nowadays use a big mainstream browser with javascript enabled. However, there
are still people, services and applications that do not use javascript. This
makes sites unavailable when they are in the "under attack" mode by Cloudflare.
This will run a check sending Cloudflare your browser information before
deciding wether you are allowed to access the website. This is yet another
privacy issue, but at the same time, a usability issue. It makes your site
unavailable to people who simply do not wish to use javascript or people who
are currently limited to a browser with no javascript support.

It is also common for Cloudflare to [Break RSS readers][rss] by presenting them
with this check. This check is often presented to common user agents used by
services and programs. Since these do not include a big javascript engine,
there is no way for them to pass the test.

## False advertising
### DDoS protection
Cloudflare is hailed by many as a gratis DDoS protection service, and they
advertise themselves as such. However, Cloudflare does not offer DDoS
protection, they simply act as a pin cushion to soak the hit. Real DDoS
protection works by analyzing traffic, spotting unusual patterns and blocking
these requests. If they were to offer real DDoS protection like this, they
would be able to tunnel TLS/SSL traffic straight to the origin server, thereby
not breaking the TLS/SSL chain as they do right now.

It should also be noted that this gratis "protection" truly gratis either. If
your site gets attacked for long enough, or for enough times in a short enough
timeframe, you will be kicked off of the gratis plan and be moved onto the
"pro" plan. This requires you to pay $200 per month for an service that does
not do what it is advertised to do. If you do not go to the pro plan, you will
have about the same protection as you would have without it, but with the
addition of ruining the privacy and security of your visitors.

### Faster page loads
This is very well explained on [joepie91's article under the heading **But The
Speed! The Speed!**][joepie]. As such, I will refer to his article instead of
repeating him here.

[joepie]: http://cryto.net/~joepie91/blog/2016/07/14/cloudflare-we-have-a-problem/
[mitm]: https://en.wikipedia.org/wiki/Man-in-the-middle_attack
[rss]: http://www.tedunangst.com/flak/post/cloudflare-and-rss
[signal-subpoena]: https://whispersystems.org/bigbrother/eastern-virginia-grand-jury/

