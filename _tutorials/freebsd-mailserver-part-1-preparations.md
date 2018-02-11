---
title: "FreeBSD email server - Part 1: Preparations"
date: 2016-10-31 07:57:50
tags: FreeBSD Email Installation
layout: post
authors:
  - ["Patrick Spek", "https://www.tyil.work"]
---

# FreeBSD email server - Part 1: Preparations
This tutorial is devised into multiple chapters to make it more manageable, and
to be able to better explain why certain parts are needed.

The tutorial is created out of experience setting up my own email server. I have
read through quite a lot of documentation so you do not have to. Nonetheless, I
would recommend doing so. Email business is a tricky one, with a lot of moving
parts that have to fit into each other. Knowing how exactly each part works will
greatly help understanding why they are needed in a proper email server.
Besides that, it will make your life a lot more enjoyable if you want to tweak
some things after this tutorial.

To kick off, some preparations should be done before you start on setting up
your own email server.

## DNS setup
Some DNS setup is required for mail. Most importantly, the MX records of a
domain. Be sure you have a domain available, otherwise, get one. There are
plenty of registrars and the price is pretty low for most domains. If you want
to look hip, get a `.email` TLD for your email server.

For the DNS records themselves, make sure you have an `A` record pointing to
the server IP you're going to use.  If you have an IPv6 address, set up an
`AAAA` record as well. Mail uses the `MX` DNS records. Make one with the value
`10 @`. If you have multiple servers, you can make MX records for these as
well, but replace the `10` with a higher value each time (`20`, `30`, etc).
These will be used as fallback, in case the server with pointed to by the `10`
record is unavailable.

## PostgreSQL
Next up you will have to install and configure [PostgreSQL][postgres]. Although
using a database is not required, this tutorial will make use of one. Using a
database makes administration easier and allows you to add a pretty basic web
interface for this task.

### Installation
Since the tutorial uses FreeBSD 11, you can install PostgreSQL easily by running

{% highlight sh %}
pkg install postgresql96-server
{% endhighlight %}

### Starting up
In order to start Postfix, you should enable the system service for it. This
way, `service` can be used to easily manage it. In addition, it will start
automatically on boot.

{% highlight sh %}
echo 'postgresql_enable="YES"' >> /etc/rc.conf.local
service postgresql start
{% endhighlight %}

### Database initialization
Since PostgreSQL is a little different than the more popular [MySQL][mysql], I
will guide you through setting up the database as well. To begin, switch user
to `postgres`, which is the default administrative user for PostgreSQL. Then
simply open up the PostgreSQL CLI.

{% highlight sh %}
su postgres
psql
{% endhighlight %}

Once you are logged in to PostgreSQL, create a new user which will hold
ownership of the database and make a database for this user.

{% highlight sql %}
CREATE USER postfix WITH PASSWORD 'incredibly-secret!';
CREATE DATABASE mail WITH OWNER postfix;
{% endhighlight %}

Once this is done, create the tables which will hold some of our configuration
data.

#### domains
{% highlight sql %}
CREATE TABLE domains (
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (name)
);
{% endhighlight %}

#### users
{% highlight sql %}
CREATE TABLE users (
    local VARCHAR(64) NOT NULL,
    domain VARCHAR(255) NOT NULL,
    password VARCHAR(128) NOT NULL,
    PRIMARY KEY (local, domain),
    FOREIGN KEY (domain) REFERENCES domains(name) ON DELETE CASCADE
);
{% endhighlight %}

#### aliases
{% highlight sql %}
CREATE TABLE aliases (
    domain VARCHAR(255),
    origin VARCHAR(256),
    destination VARCHAR(256),
    PRIMARY KEY (origin, destination),
    FOREIGN KEY (domain) REFERENCES domains(name) ON DELETE CASCADE
);
{% endhighlight %}

## Let's Encrypt
### Installation
Installing the [Let's Encrypt][letsencrypt] client is just as straightforward
as the PostgreSQL database, using `pkg`.

{% highlight sh %}
pkg install py27-certbot
{% endhighlight %}

### Getting a certificate
Requesting a certificate requires your DNS entries to properly resolve. If they
do not resolve yet, Let's Encrypt will bother you with errors. If they do
resolve correctly, use `certbot` to get your certificate.

{% highlight sh %}
certbot certonly --standalone -d domain.tld
{% endhighlight %}

## Conclusion
This should be everything required to get started on setting up your own email
server. Continue to [part 2][part-2] of this series to start setting up
Postfix.

[freebsd]: https://www.freebsd.org/
[letsencrypt]: https://letsencrypt.org/
[mysql]: https://www.mysql.com/
[part-2]: https://www.tyil.work/tutorials/freebsd-mailserver-part-2-mailing-with-postfix.html
[postgres]: https://www.postgresql.org/

