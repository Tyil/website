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

use strict;
use utf8;
use warnings;

use DBI;
use File::Glob qw( bsd_glob )

# make sure the user is root
if ($EUID != 0) {
	die "You must run this script as root\n";
}

# connect to the database
my $dsn = 'dbi:Pg:dbname=mail;host=127.1;port=5432';
my $dbh = DBI->connect($dsn, 'postgres', 'nope')
	or die 'Could not connect to the database: ' . $DBI::errstr;

# prepare a statement to select all domains
my $select = $dbh->prepare('SELECT name FROM domains;');
$select->execute();

while (my $result = $select->fetchrow_hashref()) {
	print "$result->{'name'}\n";

	my $domain = $result->{name};
	my $dkim_dir = "/srv/dkim/$domain";

	if (! -d $dkim_dir) {
		mkdir($dkim_dir);
	}

	my @keys = glob($dkim_dir . "/*.private");

	if (@keys) {
		my $date = '20161201';

		# create a new key
		print "  Generating key at $dkim_dir/$date.private\n";

		system (
			'opendkim-genkey',
			-D => $dkim_dir,
			-b => 4096,
			-r,
			-s => $date,
			-d => $domain
		)
			or die "Generating key failed: $!\n";

		# set permissions
		my $gid = getgrnam('mailnull')
			or die "Failed to retrieve the gid of mailnull\n";
		my $uid = getpwnam('mailnull')
			or die "Failed to retrieve the uid of mailnull\n";

		chown($uid, $gid,
			$dkim_dir,
			"$dkim_dir/$date.private",
			"$dkim_dir/$date.txt"
		);
	}

	foreach my $txt (bsd_glob "$dkim_dir/*.txt") {
		print "  $txt\n";

		open(my $fh, '<', $txt)
			or die;

		while (<$fh>) {
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

