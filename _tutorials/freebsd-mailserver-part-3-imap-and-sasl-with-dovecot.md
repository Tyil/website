---
title: "FreeBSD email server - Part 3: IMAP and SASL with Dovecot"
date: 2016-10-31 07:57:50
tags: FreeBSD Email Installation
layout: post
authors:
  - ["Patrick Spek", "https://www.tyil.work"]
---

# FreeBSD email server - Part 3: IMAP and SASL with Dovecot
Welcome to the second part of my FreeBSD email server series. In this series, I
will guide you through setting up your own email service. Be sure to read the
previous parts before trying to continue on this part in case you have not done
so yet.

This part will guide you through setting up [Dovecot][dovecot]. This service
will deal with the SASL authentication to your email server and making your email
boxes accessible via IMAP. While this guide does not cover POP3 functionality,
Dovecot can handle this as well.

Just like the Postfix setup, Dovecot has quite a few configuration options to
set before it will work as expected in this setup. If you have questions after
reading the full guide, please find me on IRC. You can find details on how to
do so on [my homepage][home].

## Installing Dovecot
Dovecot will also be installed from the ports tree from FreeBSD. As this guide
assumes you are working through them in order, explanation of acquiring the
ports tree will be omitted here.

You can start the installation procedure with the following commands.

{% highlight sh %}
cd /usr/ports/mail/dovecot2
make configure install
{% endhighlight %}

Again, like with the Postfix installation, leave the default options on and add
the `PGSQL` option so Dovecot can use PostgreSQL as the database back-end.

## Enabling Dovecot
Enable the Dovecot service for rcinit.

{% highlight sh %}
echo 'dovecot_enable="YES"' >> /etc/rc.conf.local
{% endhighlight %}

## Configuring Dovecot
To start of with Dovecot configuration, copy over the sample files first.

{% highlight sh %}
cp -r /usr/local/etc/dovecot/example-config/* /usr/local/etc/dovecot/.
{% endhighlight %}

Now you can start editing a number of pesky files. The file names of the
headings all appear relative to `/usr/local/etc/dovecot`.

### dovecot.conf
Here you only have to set which protocols you want to enable. Set them as
follows.

{% highlight ini %}
protocols = imap lmtp
{% endhighlight %}

### conf.d/10-master.cf
The `master.cf` configuration file indicates which sockets Dovecot should use
and provide and as which user its processes should be ran. Keep the defaults as
they are, with the exception of the following two blocks.

#### service imap-login
This will enable imaps, IMAP over SSL, and disable plain IMAP.

{% highlight ini %}
service-imap-login {
    inet_listener imap {
        port = 0
    }

    inet_listener imaps {
        port = 993
        ssl = yes
    }
}
{% endhighlight %}

#### services
This will instruct Dovecot to provide a service for authentication and `lmtp`
the **local mail transport protocol**. This is required to deliver the email
files into the correct email box location in the file system.

{% highlight ini %}
service auth {
    unix_listener auth-userdb {
        mode = 0600
        user = postfix
        group = postfix
    }

    unix_listener /var/spool/postfix/private/auth {
        mode = 0666
        user = postfix
        group = postfix
    }

    user = dovecot
}

service lmtp {
    unix_listener /var/spool/postfix/private/dovecot-lmtp {
        mode = 0600
        user = postfix
        group = postfix
    }
}

service auth-worker {
    user = postfix
}
{% endhighlight %}

### conf.d/10-ssl.conf
Here you have to enable SSL and provide the correct paths to your SSL key in
order for Dovecot to work with them.

{% highlight ini %}
ssl = required
ssl_cert = < /usr/local/etc/letsencrypt/live/domain.tld/fullchain.pem
ssl_key = < /usr/local/etc/letsencrypt/live/domain.tld/privkey.pem
{% endhighlight %}

### conf.d/10-mail.conf
The mail.conf location instructs Dovecot which location to appoint for storing
the email files. `%d` expands to the domain name, while `%n` expands to the
local part of the email address.

{% highlight ini %}
mail_home = /srv/mail/%d/%n
mail_location = maildir:~/Maildir
{% endhighlight %}

Make sure the location set by `mail_home` exists and is owned by `postfix`!

{% highlight sh %}
mkdir -p /srv/mail
chown postfix:postfix /srv/mail
{% endhighlight %}

### conf.d/10-auth.conf
This file deals with the authentication provided by Dovecot. Mostly, which
mechanisms should be supported and what mechanism should be used to get the
actual credentials to check against.  Make sure the following options are set
as given

{% highlight ini %}
disable_plaintext_auth = yes
auth_mechanisms = plain 
{% endhighlight %}

Also, make sure `!include auth-system.conf.ext` is commented **out**. It is not
commented out by default, so you will have to do this manually. In addition,
you have to uncomment `!include auth-sql.conf.ext`.

### conf.d/auth-sql.conf.ext
This is the file included from `10-auth.conf`. It instructs Dovecot to use SQL as
the driver for the password and user back-ends.

{% highlight ini %}
passdb {
    driver = sql
    args = /usr/local/etc/dovecot/dovecot-sql-conf.ext
}

userdb {
    driver = prefetch
}

userdb {
    driver = sql
    args = /usr/local/etc/dovecot/dovecot-sql-conf.ext
}
{% endhighlight %}

### dovecot-sql.conf.ext
The final configuration file entails the queries which should be used to get the
required information about the users. Make sure to update the `password` and possibly
other parameters used to connect to the database. You may have to update the `125` as
well, as this has to be identical to the `UID` of `postfix`.

As a side note, if you are following this tutorial on a machine that does
**not** support Blowfish in the default glib, which is nearly every GNU+Linux
setup, you **can not** use `BLF-CRYPT` as the `default_pass_scheme`. You will
have to settle for the `SHA-512` scheme instead.

{% highlight ini %}
driver = pgsql
connect = host=127.1 dbname=mail user=postfix password=incredibly-secret!
default_pass_scheme = BLF-CRYPT
password_query = \
    SELECT \
        local AS user, \
        password, \
        '/srv/mail/%d/%n' AS userdb_home, \
        125 AS userdb_uid, \
        125 AS userdb_gid \
    FROM users \
    WHERE local='%n' AND domain='%d';

user_query = \
    SELECT \
        '/srv/mail/%d/%n' AS home \
        125 AS uid, \
        125 AS gid \
    FROM users \
    WHERE local='%n' AND domain='%d';
{% endhighlight %}

## Conclusion
After this part, you should be left with a functioning email server that
provides IMAP over a secure connection. While this is great on itself, for
actual use in the wild, you should setup some additional services. Therefore,
in the next part, we will deal with practices that "authenticate" your emails
as legit messages. Be sure to read up on it!

[dovecot]: http://dovecot.org/
[home]: https://www.tyil.work/

