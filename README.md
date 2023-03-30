# deploy

This is a Makefile-based deployment system for syncing git repositories across several web hosts.

For those who haven't graduated to [GitHub Actions](https://docs.github.com/en/actions) or [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) or another continuous delivery solution, I offer this. You can run it in any directory at any time for any server under your stewardship.

[Phony targets](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html) have probably never been so abused.

## usage

```shell
$ deploy server.org
```

This will update any plugins and themes for the given domain and any subdomains. If you had a plugin and theme on the site, and it had a production domain (`server.org`) and development domain (`dev.server.org`), four repositories would be synced with a single command.

## overview

There are three syncing mechanisms:

1. [git](https://git-scm.com). The command `git pull` is executed on a given branch in a folder on a remote server.
1. [rsync](https://rsync.samba.org). A local folder is synced with a folder on a remote server. Only newer files are copied.
1. [wp cli](https://wp-cli.org). A `wp plugin update` or `wp theme update` command is executed on a WordPress instance (folder / path) on a remote server via SSH. This requires `wp` to be installed on the remote server.

In all of the above cases, SSH aliases in `~/.ssh/config` are used.

## features

Via a single command, you may...

+ Update all custom plugins and themes on a website and its subdomains.
+ Update all custom plugins and themes for a given client (on multiple websites).
+ Update all custom plugins and themes for a given web host (for multiple clients).
+ Update all custom plugins and themes on all websites for all clients: `$ make all`.

### local targets

If you're familiar with make's syntax, you can add local targets in the current directory by dropping them into `./targets.makefile`.

## prerequisites

+ [GNU make](https://www.gnu.org/software/make/).
+ SSH public-key authentication on the remote hosts.
+ SSH aliases in `~/.ssh/config`.
+ Plugins need to be named with a "-plugin" suffix (e.g., "foo-plugin").
+ Themes need to be named with a "-theme" suffix (e.g., "bar-theme").
+ Both domain and subdomain folders need to be located in the home directory on the remote server. If they are not (Bluehost places subdomains in a subfolder of `~/public_html`), create symbolic links:

```shell
remote-host $ ln -s ~/public_html/dev.server.org ~/dev.server.org
```

## instructions

Create a file named `websites.tsv` with the following fields separated by tabs:

| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|--------|-------------|-----------|------------|----------|--------------|-------|---------|--------|
| domain | remote host | subfolder | subdomains | function | dependencies | alias | webhost | client |
| whatever.org | ssh_alias | whatever.org | dev, staging | git | foo-plugin, bar-theme | what | dreamhost | bzmn |

+ Multiple subdomains and multiple dependencies are separated by commas.
+ For rsync workflows, the subfolder in column 3 is the local path relative to the `LOCAL_PATH_PREFIX` variable in the `Makefile`.
+ Add a comment by prepending a "#" sign to the beginning of the line.

**Tip:** I use a spreadsheet program to edit this file.

## installation

Download or clone the repository some place nice, like `~/bin/deploy`. I made an alias to make execution more convenient and to make the command available anywhere:

```shell
$ echo "alias deploy='make -f ~/bin/deploy/Makefile'" >> ~/.zshrc
$ source ~/.zshrc
```

### configuration

+ Check out the variables at the top of the `Makefile`. In particular, you may wish to edit `GIT_BRANCH`.
+ Edit `excluded.txt` for path names and patterns that rsync should not copy to the remote server.

## misc

There's some code to make exceptions for [my own plugin](https://github.com/baizmandesign/baizman-design-standard-library-wp-plugin). This code can be ignored or removed.