---
title: Setup IMAP mailserver on FreeBSD
layout: post
wip: true
authors:
  - ["Patrick Spek", "https://www.tyil.work"]
---

# Mailserver on FreeBSD
This tutorial is to setup your own mailserver using [FreeBSD][freebsd] as
[OS][wiki-os], [postfix][postfix] and [dovecot][dovecot] for handling the mail,
[PostgreSQL][postgresql] for storing our domains and addresses, [Let's
Encrypt][letsencrypt] for the SSL certificate and [DKIM][dkim], [SPF][spf] and
[DMARC][dmarc] for mail authentication.

The settings used throughout this tutorial are as follows. You will have to
adapt these values whenever you see them in this tutorial to match your own
configuration.

- **domain**: `domain.tld`
- **local mail user**: `postfix`
- **postfix UID**: `125`
- **postfix GID**: `125`
- **database name**: `mail`
- **database user**: `postfix`
- **database password**: `incredibly-secret!`

## Install required packages
Some packages can be used from the binary package manager `pkg`, but for others
we will need to compile in some additional support.

### Binary packages
```
pkg install postgresql96-server py27-certbot opendkim py27-postfix-policyd-spf-python
```

### Ports
```
portsnap fetch extract
```

#### Postfix
```
cd /usr/ports/mail/postfix
make configure install
```

Enable the following options in addition to the defaults for `postfix`:

- `PGSQL`

#### Dovecot
```
cd /usr/ports/mail/dovecot2
make configure install
```

Enable the following options in addition to the defaults for `dovecot2`:

- `PGSQL`

## Get an SSL certificate from Let's Encrypt
```
# todo!
```

### Setup a cronjob to automatically refresh the certificate
```
# todo!
```

## Configure postgresql
### Create user and database
```
su postgres
psql
CREATE USER postfix WITH PASSWORD 'incredibly-secret!';
CREATE DATABASE mail WITH OWNER postfix;
```

### Create tables
Be sure to create the following tables as `postfix`.

#### domains
```
CREATE TABLE domains (
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (name)
);
```

#### users
```
CREATE TABLE users (
    local VARCHAR(64) NOT NULL,
    domain VARCHAR(255) NOT NULL,
    password VARCHAR(128) NOT NULL,
    PRIMARY KEY (local, domain),
    FOREIGN KEY (domain) REFERENCES domains(name) ON DELETE CASCADE
);
```

#### aliases
```
CREATE TABLE aliases (
    domain VARCHAR(255),
    origin VARCHAR(256),
    destination VARCHAR(256),
    PRIMARY KEY (origin, destination),
    FOREIGN KEY (domain) REFERENCES domains(name) ON DELETE CASCADE
);
```

## Configure Postfix
### main.cf
`/usr/local/etc/postfix/main.cf`:

```
# compatability
compatability_level = 2

# directory paths
queue_directory = /var/spool/postfix
command_directory = /usr/local/sbin
daemon_directory = /usr/local/libexec/postfix
data_directory = /var/db/postfix

# domain configuration
myhostname = mail.domain.tld
mydomain = domain.tld
myorigin = $mydomain

# receiving mail
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost

# reject unknown recipients
unknown_local_recipient_reject_code = 550

# trust
mynetworks_style = host

# address extensions
recipient_delimiter = +

# virtual domain setup
virtual_mailbox_base = /srv/mail
virtual_mailbox_domains = pgsql:/usr/local/etc/postfix/pgsql-virtual-domains.cf
virtual_mailbox_maps = pgsql:/usr/local/etc/postfix/pgsql-virtual-users.cf
virtual_alias_maps = pgsql:/usr/local/etc/postfix/pgsql-virtual-aliases.cf
virtual_uid_maps = static:125
virtual_gid_maps = static:125
virtual_transport = lmtp:unix:private/dovecot-lmtp

# tls setup
smtpd_tls_cert_file = /usr/local/etc/letsencrypt/live/domain.tld/fullchain.pem
smtpd_tls_key_file = /usr/local/etc/letsencrypt/live/domain.tld/privkey.pem
smtpd_use_tls = yes
smtpd_tls_auth_only = yes

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
    
# debugging control
debug_peer_level = 2
debugger_command =
    PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/binary
    ddd $daemon_directory/$process_name $process_id & sleep 5
    
# install-time configuration
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
```

### master.cf
In the `master.cf` configuration file, you should uncomment the `submission`
service and add make it look like the following:

```
submission  inet  n  -  n  -  -  smtpd
    -o syslog_name=postfix/submission
    -o smtpd_tls_security_level=encrypt
    -o smtpd_sasl_auth_enable=yes
    -o smtpd_reject_unlisted_recipient=no
    -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject
    -o milter_macro_daemon_name=ORIGINATING
```

### pgsql-virtual-domains.cf
```
user = postgres
password = incredibly-secret!
hosts = 127.1
dbname = mail
query = SELECT 1 FROM domains WHERE name='%s';
```

### pgsql-virtual-users.cf
```
user = postgres
password = incredibly-secret!
hosts = 127.1
dbname = mail
query = SELECT 1 FROM users WHERE local='%u' AND domain='%d';
```

### pgsql-virtual-aliases.cf
```
user = postfix
password = nope
hosts = 127.1
dbname = mail
query = SELECT destination FROM aliases WHERE origin='%s';
```


## Configure Dovecot

Install the example configs

```
cp -r /usr/local/etc/dovecot/example-config/* /usr/local/etc/dovecot/.
```

### dovecot.conf
Set the following options:

```
protocols = imap lmtp
```

### conf.d/10-master.conf
Disable non-SSL ports:

```
service imap-login {
    inet_listener imap {
        port = 0
    }

    inet_listener imaps {
        port = 993
        ssl = yes
    }
}
```

Configure the auth service:

```
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
```

### conf.d/10-mail.conf
```
mail_home = /srv/mail/%d/%n
mail_location = maildir:~/Maildir
```

Create the required directories and set the correct permissions:

```
mkdir -p /srv/mail
chown postfix:postfix /srv/mail
```

### conf.d/10-auth.conf
```
disable_plaintext_auth = yes
auth_mechanisms = plain [login?] # check if login can be omitted
```

Add a `#` to `!include auth-system.conf.ext` to disable it and remove the `#`
from `#!include auth-sql.conf.ext` to enable this instead.

### conf.d/auth-sql.conf.ext
```
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
```

### dovecot-sql.conf.ext
```
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
```

### conf.d/10-ssl.conf
```
ssl = required
ssl_cert = < /usr/local/etc/letsencrypt/live/domain.tld/fullchain.pem
ssl_key = < /usr/local/etc/letsencrypt/live/domain.tld/privkey.pem
```

## DKIM
### Configuration
Write the following configuration into `/usr/local/etc/mail/opendkim.conf`:

```
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
KeyFile   /srv/dkim/domain.tld
Selector  mail
```

### Enable DKIM in postfix
Append the following configuration block to `/usr/local/etc/postfix/main.cf`:

```
# milters
milter_protocol = 2
milter_default_action = reject
smtpd_milters = 
    inet:localhost:8891
non_smtpd_milters =
    inet:localhost:8891
```

### Generate DKIM keys
```
cd /srv/dkim
opendkim-genkey -D /srv/dkim -b 4096 -r -s $(date +%Y%m%d) -d domain.tld
mv $(date +%Y%m%d).private domain.tld-$(date +%Y%m%d).private
mv $(date +%Y%m%d).txt domain.tld-$(date +%Y%m%d).txt
chown -R postfix:wheel /srv/dkim
```

### Enable the key for a domain
Next, add the keys to the opendkim tables so opendkim knows what to use:

```
echo '*@domain.tld  domain.tld' >> /usr/local/etc/opendkim/signing.table
echo "domain.tld  domain.tld:$(date +%Y%m%d):/srv/dkim/domain.tld-$(date +%Y%m%d).private" >> /usr/local/etc/opendkim/key.table
```

Finally, you should update your DNS records to contain the TXT record as shown
in `domain.tld-YYYYMMDD.private`. Save the contents between the double quotes as
the value for a TXT record with the name `YYYYMMDD._domainkey`.

## SPF
Add the following policy service to `/usr/local/etc/postfix/master.cf`:

```
policyd-spf  unix  -  n  n  -  0  spawn
    user=nobody argv=/usr/local/bin/policyd-spf
```

And add the SPF policy to the `main.cf` as well:

```
smtpd_recipient_restrictions =
    ...
    reject_unauth_destination
    check_policy_service unix:private/policyd-spf
    ...

policyd-spf_time_limit = 3600
```

## DMARC
DMARC requires yet another DNS TXT record to be added. The value of this record
should be `v=DMARC1; p=none`, which basically says you have dmarc, but you are
not doing anything with it. The record should be saved as `_dmarc` for the domain.

Once everything is working fine, you should update your DMARC record to actually
do things for you. There are a few tags you can use to inform the receiving
party on how to deal with mail from your end.

A common deployment practice for DMARC is to put the policy on `quarantine`, and
the `pct` on a low value. Slowly increase the `pct` tag up to 100. If no errors
arise, change the `pct` back to a low value again, but update the policy to
`reject`. Again, slowly increase the `pct` tag up to 100. Be sure to read the
DMARC reports as well, these can contain valuable information if it does not
work as expected. If you just want a standard value to put in and change from
time to time, you can use
`v=DMARC1; p=quarantice; pct=20; rua=mailto:postmaster@domain.tld;aspf=r`. Just
increase the `pct` by 10 each week. If you want to know more about DMARC (which
you should!), you can read the subheadings for this topic.

### v
`v` is the protocol version of DMARC. It must always be the first tag, and
currently it must always be `DMARC1`.

### p
`p` is the policy for the domain with regards to messages that fail
authentication. This tag is also required, just like the `v` tag. There are
three possible values for this tag: `none`, indicating no action, `quarantine`,
which will result in the messages being marked as *spam*, and `reject`, which
will drop the message before it lands in a receiving user's mailbox. I would
suggest setting the policy to `quarantine` at first. If nothing breaks anywhere,
you can set it to `reject`.

### pct
`pct` indicates the percentage of messages that should be filtered. It is a
number between 0 and 100.

### rua
`rua` stands for the *Reporting URI of Aggregate reports*. Commonly, it is set
to an email address to collect the reports on so the mail administrator can look
into these reports. The value can be any URI as used in an anchor tag in HTML,
so `mailto:postmaster@domain.tld` will send the mails to your postmaster
mailbox.

### sp
`sp` is the policy for subdomains. This allows you to indicate wether the
receiving server should accept mail from `sub.domain.tld` as well.

### aspf
`aspf` sets the alignment for SPF. It can be `r` for *relaxed* or `s` for
*strict*. Relaxed allows partial SPF matches, while strict requires an exact
match.

## System services
### Enabling
```
# disable the default sendmail system
echo 'daily_clean_hoststat_enable="NO"' >> /etc/periodic.conf.local
echo 'daily_status_mail_rejects_enable="NO"' >> /etc/periodic.conf.local
echo 'daily_status_include_submit_mailq="NO"' >> /etc/periodic.conf.local
echo 'daily_submit_queuerun="NO"' >> /etc/periodic.conf.local
echo 'sendmail_enable="NONE"' >> /etc/rc.conf.local

# enable postfix and friends
echo 'postfix_enable="YES"' >> /etc/rc.conf.local
echo 'dovecot_enable="YES"' >> /etc/rc.conf.local
echo 'postgresql_enable="YES"' >> /etc/rc.conf.local
echo 'milteropendkim_enable="YES"' >> /etc/rc.conf.local
```

### Starting
```
service postgresql start
service postfix start
service dovecot start
service milter-opendkim start
```

## Using your new settings
### Create a domain
```
INSERT INTO domains (name) VALUES ('domain.tld');
```

### Create a user
```
INSERT INTO users (local, domain, password)
VALUES
('test', 'domain.tld', '{SHA512-CRYPT}$6$P2K2DgjW62SMJPCc$d2ZYjcRgFING1uqO59.aobinIqAUABGAWGnv9njeCu/nPcAz5xpHOvs3MqpXEUeOBu9qpQk4csxzYQvW.yRGh0');
```

**DO NOT USE THIS PASSWORD ON YOUR LIVE SETUP!** This password is a simple
SHA512 hash of the easy to break password `test`. It's usable to quickly test if
your setup is working, but beyond this it should not be used. Choose a secure
password and hash it with BLF-CRYPT, then use that.

### MUA settings
#### IMAP
SSL/TLS on port 993

#### SMTP
STARTTLS on port 587

[dkim]: http://www.dkim.org/
[dmarc]: http://dmarc.org/
[dovecot]: http://dovecot.org/
[freebsd]: https://www.freebsd.org/
[letsencrypt]: https://letsencrypt.org/
[postfix]: http://www.postfix.org/
[postgresql]: https://www.postgresql.org/
[spf]: https://en.wikipedia.org/wiki/Sender_Policy_Framework
[wiki-os]: https://en.wikipedia.org/wiki/Operating_system

