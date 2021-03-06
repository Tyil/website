---
title: Setup nginx with Let's Encrypt SSL
date: 2016-10-25 08:00:34
tags: Installation LetsEncrypt Nginx SSL Encryption
layout: post
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# Setup nginx with Let's Encrypt SSL
This is a small tutorial to setup nginx with Let's Encrypt on a FreeBSD server
to host a static site.

## Install required software
First you have to install all the packages we need in order to get this server
going:

{% highlight sh %}
pkg install nginx py27-certbot
{% endhighlight %}

## Configure nginx
Next is nginx. To make life easier, you should configure nginx to read all
configuration files from another directory. This allows you to store all your sites in
separate configurations in a separate directory. Such a setup is a regular site on
nginx installations on GNU+Linux distributions, but not default on FreeBSD.

Open up `/usr/local/etc/nginx/nginx.conf` and make the contents of the `http`
block look a as follows:

{% highlight nginx %}
http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile     on;
    #tcp_nopush  on;

    keepalive_timeout  65;

    # default paths
    index index.html;

    # disable gzip - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=773332
    gzip  off;

    # default ssl settings
    ssl_session_cache          shared:SSL:1m;
    ssl_session_timeout        5m;
    ssl_ciphers                HIGH:!aNULL:!MD5:!AES128:!CAMELLIA128;
    ssl_protocols              TLSv1.2;
    ssl_prefer_server_ciphers  on;
    ssl_dhparam                /usr/local/etc/ssl/dhparam.pem;

    # default logs
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/acces.log;

    # default server
    server {
        listen       80;
        server_name  localhost;

        location / {
            root   /usr/local/www/nginx;
            index  index.html index.htm;
        }

        error_page  404              /404.html;
        error_page  500 502 503 504  /50x.html;

        location = /50x.html {
            root   /usr/local/www/nginx-dist;
        }
    }

    # include site-specific configs
    include sites/*.conf;
}
{% endhighlight %}

This sets default ssl settings for all server blocks that enable ssl. Note that
these are settings I use, and are in no way guaranteed to be perfect. I did some
minor research on these settings to get an acceptable rating on
[SSL Labs][ssllabs]. However, security is not standing still, and there is a
decent chance that my settings will become outdated. If you have better settings
that result in a safer setup, please [contact me][contact].

### Setup HTTP
Due to the way `certbot` works, you need a functioning web server. Since there
is no usable cert yet, this means hosting a HTTP version first. The tutorial
assumes a static HTML website to be hosted, so the configuration is pretty
easy.

Put the following in `/usr/local/etc/nginx/sites/domain.conf`:

{% highlight nginx %}
# static HTTP
server {
    # listeners
    listen 80;
    server_name domain.tld www.domain.tld;

    # site path
    root /srv/www/domain/_site;

    # / handler
    location / {
        try_files $uri $uri/ =404;
    }

    # logs
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
}
{% endhighlight %}

If your site's sources do not reside in `/srv/www/domain/_site`, change the
path accordingly. This guide will continue using this path for all examples, so
be sure to modify this where needed. In the same vein, the domain `domain.tld`
will be used. Modify this to your own domain.

### Start nginx
Nginx is now configured to host a single site over HTTP. Now is the time to enable
the nginx service. Execute the following:

{% highlight sh %}
echo 'nginx_enable="YES"' >> /etc/rc.conf.local
{% endhighlight %}

This will enable nginx as a system service. On reboots, it will be started
automatically. You can also start it up without rebooting by running the
following:

{% highlight sh %}
service nginx start
{% endhighlight %}

## Configure Let's Encrypt
Nginx is now running as your web server on port 80. Now you can request Let's
Encrypt certificates using `certbot`. You can do so as follows:

{% highlight sh %}
certbot certonly --webroot -w /srv/www/domain/_site -d domain.tld -d www.domain.tld
{% endhighlight %}

In case you want to add any sub domains, simply add more `-d sub.domain.tld`
arguments at the end. If the DNS entries for the domains resolve properly, and
no unexpected errors occur on the Let's Encrypt side, you should see a message
congratulating you with your new certs.

If your domains do not resolve correctly, `certbot` will complain about this.
You will have to resolve your DNS issues before attempting again.

If `certbot` complains about an unexpected error on their side, wait a couple
minutes and retry the command. It should work, eventually.

Once `certbot` has ran without errors, the required files should be available
in `/usr/local/etc/letsencrypt/live/domain.tld`.

## Configure nginx with SSL
The certificate has been issued and base nginx is running. Now is the time to
re-configure your site on nginx to host the HTTPS version of your site instead.
Open up `/usr/local/etc/nginx/sites/domain.conf` again, and make the contents
look like the following:

{% highlight nginx %}
# redirect HTTPS
server {
    # listeners
    listen 80;
    server_name domain.tld *.domain.tld;

    # redirects
    return 301 https://$host$request_uri;
}

# static HTTPS
server {
    # listeners
    listen  443 ssl;
    server_name  domain.tld www.domain.tld;

    # site path
    root  /srv/www/domain/_site;

    # / handler
    location / {
            try_files $uri $uri/ =404;
    }

    # enable HSTS
    add_header  Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

    # keys
    ssl_certificate      /usr/local/etc/letsencrypt/live/domain.tld/fullchain.pem;
    ssl_certificate_key  /usr/local/etc/letsencrypt/live/domain.tld/privkey.pem;
}
{% endhighlight %}

Do not forget to update all the paths to match your setup!

As a final step, you should generate the dhparam file. This is to avoid the
issues as described on [Weak DH][weakdh].

{% highlight sh %}
openssl gendh -out /usr/local/etc/ssl/dhparam.pem 4096
{% endhighlight %}

Be aware that this step can take a **very** long time. On the test machine I
used to test this tutorial, with 1 core and 1 GB ram, it took nearly 1 hour to
generate this file.

### Reload nginx
The final step is to reload the nginx configuration so it hosts the SSL version
of your site, and redirects the HTTP version to the HTTPS version. To do this,
simply run

{% highlight sh %}
service nginx reload
{% endhighlight %}

That should be all to get your site working with HTTP redirecting to HTTPS, and
HTTPS running using a gratis Let's Encrypt certificate.

[contact]: https://www.tyil.work/
[ssllabs]: https://www.ssllabs.com/ssltest/analyze.html?d=tyil.work&latest
[weakdh]: https://weakdh.org/

