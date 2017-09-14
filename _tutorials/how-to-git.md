---
title: "How to: git"
layout: post
authors:
  - ["Patrick Spek", "http://tyil.work"]
---

# How to: git
This guide will explain how to use `git` more efficiently, and why you should
use it as such.

## Forking
When working in a team, there's generally a remote server which is used to sync
your repositories. There are gratis services, such as [GitHub][github],
[Gitlab][gitlab], [GOGS][gogs], and others. These services also allow you to
*fork* a repository. This basically makes a copy of the entire repository for
your own use. In it, you have full control over the branches, tags, merge
process and everything else you want to do with it.

One the main reasons to do this is so you do not have to clutter up the main
repository with a ton of branches (these are explained later in the post). If
there are two people working in the same branch, it can help reduce conflicts,
as each developer is working on the branch in his own fork.

As such, **always** use a fork. If the service does not have a fancy button for
you to click, you can still fork manually. Simply clone their repository as
usual, set a new remote and push it there:

{% highlight sh %}
git clone git@domain.tld:them/repo.git
cd repo
git remote rename origin upstream
git remote add origin git@domain.tld:you/repo.git
git push origin master
{% endhighlight %}

The default naming convention uses `upstream` for the base of your fork, and
`origin` for your remote version of the repository. If a merge request is
accepted on the original repo, you can apply it to your fork using

{% highlight sh %}
git pull upstream master
{% endhighlight %}

## Branching
Branching is the art of using separate branches to introduce new code into your
`master` branch. Every git repository starts with a `master` branch by default.
This is the *main* branch of your repository.

Every time you want to add new code to your project, make a branch for the
feature or issue you are trying to solve. This way, you can commit freely
without having to worry about having untested or possibly broken code in the
`master` branch. If something were to come up with a higher priority, such as a
critical bug, you can simply create a new branch off of `master`, fix it and
merge that back into `master`, without having to worry about that other feature
you were working on, which is not in a releasable state yet. Once the fix is
applied, you go back to your feature branch on continue working on the cool new
stuff you wanted to implement. Now, the bug is fixed, and no code has been
released that should not have been released. If that's not convincing enough,
try some of the [Stack Overflow posts][so-git-branch] on this very topic.

Branches can be made at your leisure, with next to no overhead on your project.
Do not be scared to play around with your code in a new branch to test
something out. You can also delete branches as quickly as you made them if you
are not satisfied with the result.

Creating branches is done using `git checkout -b new-branch`. If you need to
switch to another existing branch to change something, use
`git checkout other-branch`. Deleting a branch can be done using
`git branch -D old-branch`. You can get a list of all branches in the
repository with `git branch`. The current branch is marked with an \*.

If you start a new branch to implement a feature, be sure to always branch off
of `master`, unless you have a very compelling reason not to do so. If you are
not sure what reasons would validate branching off of another branch, you
should just branch off of `master`. If you branch off of another branch, you
will have the commit history of the other branch. This often includes commits
not accepted into master yet, which might result into commits getting into
master which should not be there (yet), or annoying merge conflicts later on.

### Merging
Using multiple branches brings along the concept of *merging* branches
together. When working in a group, this is generally done by maintainers of the
upstream repository, via a *merge request*. For some reason, certain services
have named this as a *pull request* instead. The base idea of the process is as
follows:

- Pull the latest `upstream/master`
- Create a new branch 
- Apply the change you want
- Issue a merge request via the service you are using
  - Generally, you want your change to be merged into their `master` branch
- Add a title and a description of your change: What does it do, and why should it be accepted
- Optionally, discuss the changes with the upstream maintainers
- Optionally, make a couple of changes to your branch, and push it again
- Upstream maintainer accepts your change

When everything worked out, the upstream repository now contains your changes.
If you pull their branch again, it will contain your code. Using the merge
request process, your code can be easily reviewed by others, and discussed if
needed.

## Committing
Whenever you have changed anything in the repository and you wish to share
these changes, you have to commit the changes. Committing in general is not
something people tend to have issues with. Simple add the changes you want to
commit using `git add` (add the `-p` switch if you want to commit only parts of
a changed file), then `git commit` and enter a descriptive message. And that is
where most annoyances come from: the commit *message*. There are no hard rules
on this forced by git itself. There are, however, some de-facto standards and
best practices which you should always follow. Even if you never intend to
share the repository with other people, having good commit messages can help
you identify a certain change when you look back into the history.

A git commit message should be short, no more than 79 characters, on the first
line. It should be readable as "this commit message will ...", where your
commit message will replace the "...". It is a de-facto standard to start your
commit message with a capital letter, and leave off a finishing period. You do
not *have* to adhere to if you hate this, but be sure that all your commits are
consistent in how they are formatted.

If you need to explain anything beyond that, such as a rationale for the
change, or things the reviewer should pay attention to in this particular
commit, you can leave an empty line and publish this message in the commit
body.

When you are using a bug tracking system, you might also want to have a footer
with additional information. On services such as [Gitlab][gitlab] and
[GitHub][github], you can close issues by adding "Closes: #1" in the commit
message footer. A full commit message with all these things might look as
follows:

```
Fix overflow issue in table rendering mechanism

An overflow issue was found in the table rendering mechanism, as explained in
CVE-0123-45678. Regression tests have been included as well.

Closes: #35
```

In order to achieve these kind of messages, you need to be sure that your
commits can fit in to this structure. This means you need to make small
commits. Having many smaller commits makes it easier to review the changes,
keep short, descriptive messages to describe each change, and revert a single
change in case it breaks something.

### Signing your commits
You can set up git to cryptographically sign each commit you make. This will
ensure that the commit you made is proven to be from you, and not someone
impersonating you. People impersonating you might try to get harmful code into
a repo where you are a trusted contributor. Having all commits signed in a
repository can contribute in verifying the integrity of the project.

Recently, [Github][github] has added the **Verified** tag to commits if the
commit contains a correct signature.

To enable signing of all commits, add the following configuration to your
`~/.gitconfig`:

{% highlight ini %}
[commit]
	gpgsign = true

[user]
	signingkey = 9ACFE193FFBC1F50
{% endhighlight %}

Ofcourse, you will have to update the value of the `signingkey` to match
the key you want to sign your commits with.

## Closing words
I hope this post will help you in your adventures with git. It is a great tool
or working on projects together, but it gets much better when you stick to some
best practices. If you have any suggestions for this post, or any questions
after finishing it, contact me via any method listed on [my home page][home].

[github]: https://github.com
[gitlab]: https://gitlab.com
[gogs]: https://gogs.io
[home]: https://tyil.work
[so-git-branch]: https://softwareengineering.stackexchange.com/questions/335654/git-what-issues-arise-from-working-directly-on-master

