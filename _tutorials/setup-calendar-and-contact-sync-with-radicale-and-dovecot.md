---
title: Setup calendar and contact sync with Radicale and Dovecot
layout: post
wip: true
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# Setup calendar and contact sync with Radicale and Dovecot
This guide is intended to help you set up your own calendar and contact server
(CalDav and CardDav) system to help you manage your own data. Before starting
on this server, be sure to [read up on the IMAP server
tutorial][tutorial-imap], as this guides you through setting up Dovecot.

## Install required packages
{% highlight sh %}
pkg install py27-radicale
{% endhighlight %}

## Configure Radicale
### `/usr/local/etc/radicale/config`
Open up the `/usr/local/etc/radicale/config` file, and update each `[block]`.

#### [server]
{% highlight ini %}
hosts = 127.1:5232
daemon = True

dns_lookup = True

base_prefix = /
can_skip_base_prefix = False

realm = Radicale - Password required
{% endhighlight %}

#### [encoding]
{% highlight ini %}
request = utf-8
stock = utf-8
{% endhighlight %}

#### [auth]
{% highlight ini %}
type = IMAP

imap_hostname = localhost
imap_port = 143
imap_ssl = False
{% endhighlight %}

#### [storage]
{% highlight ini %}
type = filesystem
filesystem_folder = /usr/local/share/radicale
{% endhighlight %}

#### [logging]
{% highlight ini %}
config = /usr/local/etc/radicale/logging
{% endhighlight %}

### `/usr/local/etc/radicale/logging`
This file is fine on the defaults in FreeBSD 11. This saves you from
configuring a little bit.

## Configure Dovecot
### Enable imap
This option was disabled in the [IMAP server tutorial][tutorial-imap], however,
if we want to auth using the same credentials as the mailserver, this option is
needed again. Be sure to setup a firewall that blocks requests from the
outside to this port, so it can only be used internally. In
`/usr/local/etc/dovecont/conf.d/10-master.conf`, enable the `imap` port
again:

{% highlight conf %}
...
service imap-login {
    inet_listener imap {
        port = 143
    }
    ...
}
...
{% endhighlight %}

## Configure nginx
To make using the service easier, you can setup [nginx][nginx] to act as a
reverse proxy. If you followed the [webserver tutorial][tutorial-webserver],
you already have the basics for this set up. I do recommend you check this out,
as I will only explain how to configure a virtual host to deal with the reverse
proxy here.

### Setup a reverse proxy
This is obviously a to-do part.

## Enable the service at startup
{% highlight sh %}
echo 'radicale_enable="YES"' >> /etc/rc.conf.local
{% endhighlight %}

## Start the server
{% highlight sh %}
service radicale start
{% endhighlight %}

[nginx]: #
[tutorial-imap]: #
[tutorial-webserver]: #

