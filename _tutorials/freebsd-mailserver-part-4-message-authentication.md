---
title: "FreeBSD email server - Part 4: Message authentication"
layout: post
wip: true
authors:
  - ["Patrick Spek", "https://www.tyil.work"]
---

# FreeBSD email server - Part 4: Message authentication
Welcome to another part in the FreeBSD email server series. This time, we are
going to setup some mechanisms to deal with message authentication. This
practice will make other email providers accept your email messages and deliver
them properly in the inbox of the receiving user, instead of their spam box.

We will do so using three of the most common practices: [SPF][spf],
[DKIM][dkim] and [DMARC][dmarc].

## DKIM
### Installation
The tools for DKIM are easily installed using `pkg`.

{% highlight sh %}
pkg install opendkim
{% endhighlight %}

### Configuration
Write the following configuration into `/usr/local/etc/mail/opendkim.conf`.

{% highlight conf %}
# logging
Syslog  yes

# permissions
UserID  postfix
UMask   007

# general settings
AutoRestart         yes
Background          yes
Canonicalization    relaxed/relaxed
DNSTimeout          5
Mode                sv
SignatureAlgorithm  rsa-sha256
SubDomains          no
X-Header            yes
OversignHeaders     From

# tables
KeyTable      /usr/local/etc/opendkim/key.table
SigningTable  /usr/local/etc/opendkim/signing.table

# socket
Socket  inet:8891@localhost

# domains
Domain    domain.tld.privkey
KeyFile   /usr/local/etc/opendkim/domain.tld
Selector  mail
{% endhighlight %}

#### Postfix
Postfix needs to be instructed to sign the messages with a DKIM header using
the opendkim service. You can do so by inserting the following configuration
block somewhere around the end of `/usr/local/etc/postfix/main.cf`.

{% highlight ini %}
# milters
milter_protocol = 2
milter_default_action = reject
smtpd_milters =
    inet:localhost:8891
    non_smtpd_milters =
    inet:localhost:8891
{% endhighlight %}

#### System service
OpenDKIM runs as a system service. As such, you will have to enable this
service in rcinit. This is a simple step, achieved with the given command.

{% highlight sh %}
echo 'milteropendkim_enable="YES"' >> /etc/rc.conf.local
{% endhighlight %}

Do not forget to actually start the service when you are done with the
tutorial!

### Creating and using keys
In order to use DKIM, you will need to generate some keys to sign the messages
with. You cannot use your Let's Encrypt SSL keys for this. First, create a
directory to house your domain's keys.

{% highlight sh %}
mkdir -p /usr/local/etc/opendkim/keys/domain.tld
chown -R postfix:wheel $_
{% endhighlight %}

Next up, generate your first key.

{% highlight sh %}
opendkim-genkey -D /usr/local/etc/opendkim/keys -b 4096 -r -s $(date +%Y%m%d) -d domain.tld
{% endhighlight %}

I tend to use the current date for the key names so I can easily sort them by
the most recent one.

Afterwards, you will have to add a line to two separate files to instruct DKIM
to use this key for a certain domain when signing mail. These are fairly
straightforward and can be done using a simple `echo` as well.

{% highlight sh %}
echo '*@domain.tld  domain.tld' >> /usr/local/etc/opendkim/signing.table
echo "domain.tld  domain.tld:$(date +%Y%m%d):/usr/local/etc/opendkim/keys/domain.tld/$(date +%Y%m%d).private" >> /usr/local/etc/opendkim/key.table
{% endhighlight %}

### Adding the DNS records
You may have already noticed that `opendkim-genkey` also creates a `.txt` file
in addition to the private key. This text file contains the DNS record value
you need to add for your domain's DNS. Add the record to your DNS server, and
simply wait for it to propagate.

## SPF
SPF is simply a DNS record that shows which IPs are allowed to email for that
domain.

### Adding the DNS records
A simple example for an SPF record is the following. It allows mail to be sent
in the domain's name from any IP listed in the MX records.

{% highlight plain %}
v=spf1 mx -all
{% endhighlight %}

## DMARC
DMARC is, like SPF, a DNS record. It tells how to deal with messages coming
from the server and where to report abuse of your server. Some of the larger
email providers send out reports to the address given in the DMARC record so
you can figure out whether someone is spamming from your servers, for example.

### Adding the DNS records
A simple DMARC policy to get started with is to quarantine all emails that fail
authentication. This means the emails will go into the receiving user's spam
box. In addition, abuse reports will be sent to the address defined in the
`rua`.

{% highlight plain %}
v=DMARC1; p=quarantine; rua=mailto:abuse@domain.tld
{% endhighlight %}

## Conclusion
These few simple measures will make receiving servers trust the authenticity of
the mails you send. In effect, your messages will be much less likely to be
marked as spam.  However, you are a target of spam as well. How you can deal
with that, will be available in the next part of this series.

[dkim]: http://www.dkim.org/
[dmarc]: http://dmarc.org/
[spf]: https://en.wikipedia.org/wiki/Sender_Policy_Framework

