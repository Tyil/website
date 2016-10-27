---
title: Setup a VPN with cjdns
layout: post
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# Setup VPN with cjdns
In this tutorial I will outline a simple setup for a [VPN][vpn] using
[`cjdns`][cjdns]. Cjdns will allow you to setup a secure mesh vpn which uses
IPv6 internally.

## Requirements
For this tutorial, I have used two client machines, both running Funtoo. A
FreeBSD 11 server is used as a global connection point.

You are ofcourse able to use any other OS or distro supported by cjdns, but you
may have to update some steps to work on your environment in that case.

## Installation of the server
### Dependencies
Before you can begin, we need some dependencies. There's only two of those, and
they are available via `pkg` to make it even easier. Install them as follows:

{% highlight sh %}
pkg install gmake node
{% endhighlight %}

### Compiling
Next up is getting the cjdns sources and compile these, as cjdns is not
available as a prebuilt package:

{% highlight sh %}
mkdir -p ~/.local/src
cd $_
git clone https://github.com/cjdelisle/cjdns.git cjdns
cd $_
./do
{% endhighlight %}

To make the compiled binary available system-wide so we can use it with a
system service, copy it to `/usr/local/bin` and rehash to make it available as
a direct command:

{% highlight sh %}
cp cjdroute /usr/local/bin/.
hash -r
{% endhighlight %}

### Configuring
Cjdns provides a flag to generate the initial configuration. This will provide
you with some sane defaults where only a couple of small changes are needed to
make it work properly. Generate these defaults with `--genconf`:

{% highlight sh %}
(umask 177 && cjdroute --genconf > /usr/local/etc/cjdroute.conf)
{% endhighlight %}

The umask will make all following commands write files using `600` permissions.
This makes sure the config file is not readable by people who shouldn't be able
to read it. Be sure to check wether the owner of the file is `root`!

Now you can start actually configuring the node to allow incoming connections.
You have to find the `authorizedPasswords` array in the `cjdroute.conf` file
and remove the contents of it. Then you can add your own machines in it. This
guide follows the assumption of two clients, so the config for two clients will
be shown here. You can add more clients if you wish, ofcourse.

{% highlight json %}
"authorizedPasswords":
[
    {"password": "aeQu6pa4Vuecai3iebah7ogeiShaeDaepha6Mae1yooThoF0oa0Eetha9oox", "user": "client_1"},
    {"password": "aiweequuthohkahx4tahLohPiezee9OhweiShoNeephe0iekai2jo9Toorah", "user": "client_2"},
]
{% endhighlight %}

If you need to generate a password, you can make use of the tool `pwgen`,
available at your local package manager. You can then generate new passwords by
running `pwgen 60 -1`. Change the `60` around if you want passwords of a
different size.

### Adding a startup service
rcinit has deceptively easy scripts to make applications available as services.
This in turn allows you to enable a service at startup. This way you can make
sure cjdns starts whenever the server boots. You can copy the following
contents directly into `/usr/local/etc/rc.d/cjdroute`:

{% highlight sh %}
#! /bin/sh

# PROVIDE: cjdroute
# KEYWORD: shutdown

#
# Add the following lines to /etc/rc.conf to enable cjdroute:
#
#cjdroute_enable="YES"

. /etc/rc.subr

name="cjdroute"
rcvar="cjdroute_enable"

load_rc_config $name

: ${cjdroute_config:=/usr/local/etc/cjdroute.conf}

command="/usr/local/bin/cjdroute"
command_args=" < ${cjdroute_config}"

run_rc_command "$1"
{% endhighlight %}

Afterwards, you must enable the service in `/etc/rc.conf.local` like follows:

{% highlight sh %}
echo 'cjdroute_enable="YES"' >> /etc/rc.conf.local
{% endhighlight %}

## Installation of the clients
### Dependencies
The dependencies are still on `gmake` and `node`, so simply install those on
your clients. This guide assumes using Funtoo for the clients, so installation
would go as follows:

{% highlight sh %}
emerge gmake nodejs
{% endhighlight %}

### Compiling
Compilation is the same as for the server, so check back there for more
information if you have already forgotten.

### Configuring
Generating the base configuration is again done using `cjdroute --genconf`,
just like on the server. On Funtoo, config files generally reside in `/etc`
instead of `/usr/local/etc`, so you should set the filepath you write the
configuration to accordingly:

{% highlight sh %}
cjdroute --genconf > /etc/cjdroute.conf
{% endhighlight %}

Setting up the connections differs as well, as the clients are going to make an
outbound connection to the server, which is configured to accept inbound
connections.

You should still clean the `authorizedPasswords` array, as it comes with a
default entry that is uncommented.

Now you can setup outbound connections on the clients. You set these up in the
`connectTo` block of `cjdroute.conf`. For this example, the IP 192.168.1.1 is
used to denote the server IP. Unsurprisingly, you should change this to your
server's actual IP. You can find the `publicKey` value at the top of your
server's `cjdroute.conf` file.

On client 1, put the following in your `cjdroute.conf`:

{% highlight json %}
"connectTo":
{
	"192.168.1.1:9416":
	{
		"login": "client_1",
		"password": "aeQu6pa4Vuecai3iebah7ogeiShaeDaepha6Mae1yooThoF0oa0Eetha9oox",
		"publicKey": "thisIsJustForAnExampleDoNotUseThisInYourConfFile_1.k"
	}
}
{% endhighlight %}

On client 2:

{% highlight json %}
"connectTo":
{
	"192.168.1.1:9416":
	{
		"login": "client_2",
		"password": "aiweequuthohkahx4tahLohPiezee9OhweiShoNeephe0iekai2jo9Toorah",
		"publicKey": "thisIsJustForAnExampleDoNotUseThisInYourConfFile_1.k"
	}
}
{% endhighlight %}

That is all for configuring the nodes.

### Adding a startup service
You probably want cjdroute to run at system startup so you can immediatly use
your VPN. For openrc based systems, such as Funtoo, cjdns comes with a ready to
use service script. To make this available to your system, copy it over to the
right directory:

{% highlight sh %}
cp ~/.local/src/cjdns/contrib/openrc/cjdns /etc/init.d/cjdroute
{% endhighlight %}

Now add the service to system startup and start the service:

{% highlight sh %}
rc-update add cjdroute default
rc-service cjdroute start
{% endhighlight %}

That should be sufficient to get cjdns up and running for an encrypted VPN. You
can find the IPs of each of your systems at the top of your `cjdroute.conf`
files, in the `ipv6` attribute.

[cjdns]: https://github.com/cjdelisle/cjdns
[vpn]: https://en.wikipedia.org/wiki/Virtual_private_network

