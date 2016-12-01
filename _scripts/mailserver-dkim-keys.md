---
layout: default
title: Mailserver DKIM keys
lang: perl 5
---

This is a little script I use to make sure all domains hosted on my email
server have DKIM keys, and to output the TXT records for the corresponding
keys. Using this I can quickly get an overview of the records I need to add to
publish the public DKIM keys.

{% highlight perl linenos %}
#!/usr/bin/env perl

use autodie;
use strict;
use utf8;
use warnings;

use DBI;

# TODO: make sure the user is root

# connect to the database
my $dsn = 'dbi:Pg:dbname=mail;host=127.1;port=5432';
my $dbh = DBI->connect($dsn, 'postgres', 'nope')
	or die 'Could not connect to the database: ' . $DBI::errstr;

# prepare a statement to select all domains
my $select = $dbh->prepare('SELECT name FROM domains;');
$select->execute();

while (my $result = $select->fetchrow_hashref()) {
	print "$result->{'name'}\n";

	if (! -d "/srv/dkim/$result->{'name'}") {
		mkdir("/srv/dkim/$result->{'name'}");
	}

	my @keys = glob("/srv/dkim/$result->{'name'}/*.private");

	if ($#keys < 0) {
		my $date = '20161201';

		# create a new key
		print "  Generating key at /srv/dkim/$result->{'name'}/$date.private\n";

		system "opendkim-genkey -D /srv/dkim/$result->{'name'} -b 4096 -r -s $date -d $result->{'name'}"
			or die "Generating key failed: $!\n";

		# set permissions
		my $gid = getgrnam('mailnull');
		my $uid = getpwnam('mailnull');

		chown($uid, $gid, "/srv/dkim/$result->{'name'}");
		chown($uid, $gid, "/srv/dkim/$result->{'name'}/$date.private");
		chown($uid, $gid, "/srv/dkim/$result->{'name'}/$date.txt");
	}

	foreach (glob "/srv/dkim/$result->{name}/*.txt") {
		print "  $_\n";

		open(my $fh, '<', $_);

		foreach (<$fh>) {
			chomp;

			if (/"(.+?)"/) {
				print "$1";
			}
		}

		print "\n";

		close($fh);
	}
}
{% endhighlight %}

