# CloudApp CLI

Experience all the pleasures of sharing with [CloudApp][] from your terminal.

[cloudapp]: http://getcloudapp.com


## Requirements

`cloudapp-cli` requires Ruby 1.9.2 or greater.


## Getting Started

``` bash
$ gem install cloudapp-cli
$ cloudapp upload screenshot.png
$ cloudapp bookmark http://getcloudapp.com
```

## Commands

### cloudapp upload

``` bash
$ cloudapp upload screenshot.png
http://cl.ly/abc123
```

### cloudapp bookmark

``` bash
$ cloudapp bookmark http://getcloudapp.com
http://cl.ly/abc123
```

## Wish List

A few simple commands to allow scripting and input from other Unix programs
would be ideal.

### Phase: Next

 - Share several files: `cloudapp upload *.png`
 - Bookmark several links: `cloudapp bookmark http://douglasadams.com http://zombo.com`
 - Handle bookmarks from STDIN: `pbpaste | cloudapp bookmark`
 - Handle files from STDIN: `find *.png | cloudapp upload`
 - Download a drop: `cloudapp download http://cl.ly/abc123`

### Phase: Unstoppable

 - Archive and share several files: `cloudapp upload --archive *.png`
 - Encrypt and share a file: `cloudapp upload --encrypt launch_codes.txt`
 - Download and decrypt and encrypted drop: `cloudapp download --key=def456 http://cl.ly/abc123`

### Phase: World Domination

While we're dreaming, what could you do if `cloudapp` had a database of all your
drops? Bonus points for a light weight daemon that kept everything in sync at
all times.

 - Find all your screen shots: `cloudapp list /^screen ?shot.*\.png$/`
 - Trash all your stale drops: `cloudapp delete --last-viewed="> 1 month ago"`
 - See your drop views in real time: `cloudapp --tail`

There's bound to be a better way to express some of these commands, but you get
the picture.
