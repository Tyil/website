---
layout: post
title:  On winmail.dat
date:   2016-10-01 10:20:27 +0200
wip:    true
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# winmail.dat
This article is intended for sysadmins who run email systems and those who
maintain the Outlook instances for their workforce. If you do not belong into
either of these categories, the following article is probably not too useful.

If you are one of the many people that suffers from a sysadmin who has yet to
fix the `winmail.dat` issues on his network, you can kindly redirect them here
and hope that they are kind enough to improve their services. If they do not,
you may want to look for a better sysadmin.

## What is this `winmail.dat`?
A `winmail.dat` is a file that Outlook will attach if an Outlook user sends an
email containing actual attachments or any kind of markup unless Outlook has
been configured not to do so. It is a binary format that holds all the
information to the markup used in the email and the actual attachment that the
user was trying to send. As is typical with Microsoft, this is incompatible
with other Microsoft products. It will only "fix" itself if the receiver is
also using Outlook.

## Why should I care?
This means that recipients of any mail sent using such a badly configured
Outlook instance cannot see any markup used by the sender, nor can the
recipient see any attachment. Most people can live without the markup, but not
being able to see the actual attachments is generally a pretty big issue.

Now, there are shady tools available to try and decode these `winmail.dat`
files, but these will not work correctly in all circumstances. Furthermore, an
end-user should not be required to depend on a shady tool to fix the symptom of
a misconfigured email client from another party.

## How can I fix this?

