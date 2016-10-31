---
title: "FreeBSD email server - Part 2: Mailing with Postfix"
layout: post
wip: true
authors:
  - ["Patrick Spek", "https://www.tyil.work"]
---

# FreeBSD email server - Part 2: Mailing with Postfix
Welcome to the second part of my FreeBSD email server series. In this series, I
will guide you through setting up your own email service. Be sure to done the
preparations from [part 1][part-1] of this series.

This part will guide you through setting up email service on your machine using
[Postfix][postfix]. Basic installation is pretty straightforward, but there is
a lot to configure. If you are not sure what some configuration options do,
please read up on them. There is a lot to do wrong with a mail server, and
doing things wrong will likely get you on a blacklist which will make other
servers stop processing the mail you are trying to send out.

Setting up Postfix is one of the harder parts of configuring a mail server. If
you have questions after reading the full guide, please find me on IRC. You can
find details on how to do so on [my homepage][home].

## Installing Postfix
Installation procedures on FreeBSD are pretty straightforward. Unlike `certbot`
from the previous part, we will need to compile Postfix from source in order to
use PostgreSQL as a database backend. Thanks to FreeBSD's
[ports][freebsd-ports], this is not difficult either. If this is your first
port to compile, you probably need to get the ports tree first. You can
download and extract this using the following command.

{% highlight sh %}
portsnap fetch extract
{% endhighlight %}

Once that has finished running, go into the directory containing the build
instructions for Postfix, and start the installation process.

{% highlight sh %}
cd /usr/ports/mail/postfix
make configure install
{% endhighlight %}

This will open a popup with a number of options you can enable or disable. The
enabled defaults are fine, but you will have to enable the `PGSQL` option. This
will allow you to use the configuration tables created in part 1.

## Enabling Postfix
Enable the Postfix service for rcinit. This allows you to use `service postfix
start` once configuration is done, and will autostart the service on system
boot. In addition, the default mailer on FreeBSD, [sendmail][sendmail] should
be disabled so nothing is in Postfix's way when trying to deal with processing
email traffic.

{% highlight sh %}
# disable the default sendmail system
echo 'daily_clean_hoststat_enable="NO"' >> /etc/periodic.conf.local
echo 'daily_status_mail_rejects_enable="NO"' >> /etc/periodic.conf.local
echo 'daily_status_include_submit_mailq="NO"' >> /etc/periodic.conf.local
echo 'daily_submit_queuerun="NO"' >> /etc/periodic.conf.local
echo 'sendmail_enable="NONE"' >> /etc/rc.conf.local

# enable postfix
echo 'postfix_enable="YES"' >> /etc/rc.conf.local
{% endhighlight %}

## Configuring Postfix
There is a ton to configure for Postfix. This configuration happens in two
files, `main.cf` and `master.cf`. Additionally, as some data is in the
PostgreSQL database, three files with information on how to query for this
information are needed. All of these files are in `/usr/local/etc/postfix`.

The guide has a comment line for most blocks. It is advised that **if** you
decide to just copy and paste the contents, you copy that along so you have
some sort of indication of what is where. This could help you out if you ever
need to change anything later on.

### main.cf
#### Compatability
The configuration file starts off by setting the compatability level. If
postfix updates the configuration scheme and deprecates certain options, you
will be notified of this in the logs.

{% highlight ini %}
# compatability
compatability_level = 2
{% endhighlight %}

#### Directory paths
These options indicate where Postfix will look and keep certain files required
for correct operation.

{% highlight ini %}
# directory paths
queue_directory = /var/spool/postfix
command_directory = /usr/local/sbin
daemon_directory = /usr/local/libexec/postfix
data_directory = /var/db/postfix
{% endhighlight %}

#### Domain configuration
The domain configuration instruct the server of the domain(s) it should serve
for. Use your FQDN without subdomains for `mydomain`. You can use a subdomain
for `myhostname`, but you are not required to. The most common setting is
using a `mail` subdomain for all mail related activities, which would
result in something like this.

{% highlight ini %}
# domain configuration
myhostname = mail.domain.tld
mydomain = domain.tld
myorigin = $mydomain
{% endhighlight %}

#### Listening directives
All internet devices it should listen on, and all domains this server should
consider itself the endpoint for, should be listed here. The defaults in the
example block are good enough, as we put some of our data in the PostgreSQL
database instead.

{% highlight ini %}
# listening directives
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost
{% endhighlight %}

#### Reject unknown recipients
How to deal with messages sent to an emailaddress whose domain points to your
server's address, but have no actual mailbox. A code of `550` means to inform
the remote server that delivery is not possible and will not be possible. This
should stop the remote server from trying it again.

{% highlight ini %}
# reject unknown recipients
unknown_local_recipient_reject_code = 550
{% endhighlight %}

#### Trust
{% highlight ini %}
# trust
mynetworks_style = host
{% endhighlight %}

#### Address extensions
This block is optional. It allows you to use email address extensions. These
are addresses with an additional character in them that will drop the email in
the unextended address' mailbox, but allows you to quickly filter on them as
the sent-to address contains the extension.

{% highlight ini %}
# address extensions
recipient_delimiter = +
{% endhighlight %}

#### Virtual domain directives
This part is where things get important. Virtual domains allow you to handle
mail for a large number of domains that are different from the actual server's
domain. This is where the database configuration comes in to play. It is
important to note the `static:125` values. The `125` should map to the `UID` of
the `postfix` user account on your system.

{% highlight ini %}
# virtual domain directives
virtual_mailbox_base = /srv/mail
virtual_mailbox_domains = pgsql:/usr/local/etc/postfix/pgsql-virtual-domains.cf
virtual_mailbox_maps = pgsql:/usr/local/etc/postfix/pgsql-virtual-users.cf
virtual_alias_maps = pgsql:/usr/local/etc/postfix/pgsql-virtual-aliases.cf
virtual_uid_maps = static:125
virtual_gid_maps = static:125
virtual_transport = lmtp:unix:private/dovecot-lmtp
{% endhighlight %}

#### TLS setup
The TLS setup configures your server to use secure connections. The keys used
here have been generated in the previous part of this series.

{% highlight ini %}
# tls setup
smtpd_tls_cert_file = /usr/local/etc/letsencrypt/live/domain.tld/fullchain.pem
smtpd_tls_key_file = /usr/local/etc/letsencrypt/live/domain.tld/privkey.pem
smtpd_use_tls = yes
smtpd_tls_auth_only = yes
{% endhighlight %}

#### SASL setup
SASL deals with the authentication of the users to your email server.

{% highlight ini %}
# sasl setup
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_recipient_restrictions =
    permit_sasl_authenticated,
    permit_mynetworks,
    reject_unauth_destination
smtpd_relay_restrictions =
    permit_sasl_authenticated,
    permit_mynetworks,
    reject_unauth_destination
{% endhighlight %}

#### Debugging
The debugging options are generally useful in case things break. If you have
little traffic, you could leave them on forever in case you want to debug
something later on. Once your server is working as intended, you should turn
these options off. The postfix logs get pretty big in a short amount of time.

{% highlight ini %}
# debugging
debug_peer_level = 2
debugger_command =
    PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/binary
    ddd $daemon_directory/$process_name $process_id & sleep 5
{% endhighlight %}

#### Installation time defaults
These options should not be touched, but are very important to have for your
server.

{% highlight ini %}
# install-time defaults
sendmail_path = /usr/local/sbin/sendmail
newaliases_path = /usr/local/bin/newaliases
mailq_path = /usr/local/bin/mailq
setgid_group = maildrop
html_directory = /usr/local/share/doc/postfix
manpage_directory = /usr/local/man
sample_directory = /usr/local/etc/postfix
readme_directory = /usr/local/share/doc/postfix
inet_protocols = ipv4
meta_directory = /usr/local/libexec/postfix
shlib_directory = /usr/local/lib/postfix
{% endhighlight %}

### master.cf
For the `master.cf` file, you can use the following configuration block.

{% highlight cfg %}
submission    inet  n       -       n       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
pickup        unix  n       -       n       60      1       pickup
cleanup       unix  n       -       n       -       0       cleanup
qmgr          unix  n       -       n       300     1       qmgr
tlsmgr        unix  -       -       n       1000?   1       tlsmgr
rewrite       unix  -       -       n       -       -       trivial-rewrite
bounce        unix  -       -       n       -       0       bounce
defer         unix  -       -       n       -       0       bounce
trace         unix  -       -       n       -       0       bounce
verify        unix  -       -       n       -       1       verify
flush         unix  n       -       n       1000?   0       flush
proxymap      unix  -       -       n       -       -       proxymap
proxywrite    unix  -       -       n       -       1       proxymap
smtp          unix  -       -       n       -       -       smtp
relay         unix  -       -       n       -       -       smtp
showq         unix  n       -       n       -       -       showq
error         unix  -       -       n       -       -       error
retry         unix  -       -       n       -       -       error
discard       unix  -       -       n       -       -       discard
local         unix  -       n       n       -       -       local
virtual       unix  -       n       n       -       -       virtual
lmtp          unix  -       -       n       -       -       lmtp
anvil         unix  -       -       n       -       1       anvil
scache        unix  -       -       n       -       1       scache
{% endhighlight %}

### SQL query files
The following three configuration files deal with the SQL query files to make
Postfix able of getting some of its configuration from a database. You
obviously have to change the first 4 directives to match your database
authentication credentials.

#### pgsql-virtual-domains.cf
{% highlight ini %}
user = postgres
password = incredibly-secret!
hosts = 127.1
dbname = mail
query = SELECT 1 FROM domains WHERE name='%s';
{% endhighlight %}

#### pgsql-virtual-users.cf
{% highlight ini %}
user = postgres
password = incredibly-secret!
hosts = 127.1
dbname = mail
query = SELECT 1 FROM users WHERE local='%u' AND domain='%d';
{% endhighlight %}

#### pgsql-virtual-aliases.cf
{% highlight ini %}
user = postfix
password = nope
hosts = 127.1
dbname = mail
query = SELECT destination FROM aliases WHERE origin='%s';
{% endhighlight %}

## Conclusion
This should be enough Postfix configuration, for now. Next part involves
Dovecot, which will enable IMAP. It will also provide the SASL mechanism
defined in this part.

[freebsd-ports]: https://www.freebsd.org/ports/
[home]: https://www.tyil.work/
[part-1]: https://www.tyil.work/tutorials/freebsd-mailserver-part-1-preparations.html
[postfix]: http://www.postfix.org/
[sendmail]: http://www.sendmail.com/sm/open_source/

