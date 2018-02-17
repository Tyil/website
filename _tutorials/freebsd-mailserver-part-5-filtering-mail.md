---
title: "FreeBSD email server - Part 5: Filtering mail"
date: 2016-10-31 20:02:19
tags: FreeBSD Email Installation
layout: post
authors:
  - ["Patrick Spek", "https://www.tyil.work"]
---

# FreeBSD email server - Part 5: Filtering mail
Being able to send mail and not be flagged as spam is pretty awesome on itself.
But you also get hit by a lot of spam. The more you give out your email address
and domain name, the more spam you will receive over time. I welcome you to
another part of the FreeBSD email server series. In this part, we will set up
email filtering at the server side.

We will accomplish this with a couple packages, [SpamAssassin][spamassassin]
and [Pigeonhole][pigeonhole]. The former deals with scanning the emails to
deduce whether it is spam or not. The latter filters messages. We will use this
filtering to drop emails marked as spam by SpamAssassin into the Junk folder,
instead of the inbox.

## Installing the packages
Both packages are available through FreeBSD's `pkg` utility. Install them as
such.

{% highlight sh %}
pkg install dovecot-pigeonhole spamassassin
{% endhighlight %}

## SpamAssassin
### Enabling the service
Like most services, you have to enable them as well. Pigeonhole is an extension
to Dovecot, and Dovecot will handle this one. SpamAssassin requires you to
configure the service as well. You can enable it and set sane configuration to
it with the following two commands.

{% highlight sh %}
echo 'spamd_enable="YES"' >> /etc/rc.conf.local
echo 'spamd_flags="-u spamd -H /srv/mail"' >> /etc/rc.conf.local
{% endhighlight %}

### Acquiring default spam rules
SpamAssassin has to "learn" what counts as *spam* and what counts as *ham*. To
fetch these rules, you should execute the updates for SpamAssassin with the
following command.

{% highlight sh %}
sa-update
{% endhighlight %}

You most likely want to run this once every while, so it is advised to setup a
[cronjob][cronjob] for this purpose.

## Postfix
In order to have mails checked by SpamAssassin, Postfix must be instructed to
pass all email through to SpamAssassin, which will hand them back with a
`X-Spam-Flag` header attached to them. This header can be used by other
applications to treat it as spam.

### master.cf
There's not much to include to the already existing Postfix configuration to
enable SpamAssassin to do its job. Just open `/usr/local/etc/postfix/master.cf`
and append the block given below.

{% highlight ini %}
spamassassin  unix  -       n       n       -       -       pipe
  user=spamd argv=/usr/local/bin/spamc
  -f -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}
{% endhighlight %}

## Pigeonhole
Pigeonhole is an implementation of Sieve for Dovecot. It deals with filtering
messages on the server side using a set of rules, defined in a file usually
named `sieve`. This file is generally saved at
`/srv/mail/domain.tld/user/sieve`. A default file to filter spam out is the
following example.

{% highlight sieve %}
require [
    "fileinto",
    "mailbox"
];

if header :contains "X-Spam-Flag" "YES" {
    fileinto :create "Junk";
    stop;
}
{% endhighlight %}

This looks for the `X-Spam-Flag` header, which is added by SpamAssassin. If it
is set to `YES`, this indicates SpamAssassin thinks the message is spam. As
such, sieve is instructed to filter this message into the folder `Junk`, and to
create this folder if it does not exist yet. The `stop;` makes sieve stop
trying to process this message further based on later rules.

## Dovecot
Dovecot needs some additional configuration to work with Pigeonhole. Modify the
following files and add the contents described.

### conf.d/20-lmtp.conf
This will enable Pigeonhole in Dovecot.

{% highlight ini %}
protocol lmtp {
  mail_plugins = $mail_plugins sieve
}
{% endhighlight %}

### conf.d/90-plugin.conf
This configures Pigeonhole to look for a file named `sieve` in the mailbox
homedir, and execute that when delivering mail.

{% highlight ini %}
plugin {
  sieve = /srv/mail/%d/%n/sieve
}
{% endhighlight %}

## Conclusion
Spam is a pain, especially if you get a lot of it. The configuration added in
this part of the FreeBSD email server series should get rid of most of it. This
also concludes the series. If you have any questions or suggestions, please
contact me via any of the methods detailed on [my home page][home].

Thanks for reading along, and enjoy your very own email server!

[cronjob]: #
[home]: https://www.tyil.work/
[pigeonhole]: http://pigeonhole.dovecot.org/
[spamassassin]: https://spamassassin.apache.org/

