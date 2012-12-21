# CloudApp CLI

Experience all the pleasures of sharing with [CloudApp][] from your terminal.

[cloudapp]: http://getcloudapp.com


## Requirements

`cloudapp` requires Ruby 1.9.2 or greater. Windows is not yet supported. If
you're willing to lend a hand, we'd love to officially support it.


## Getting Started

``` bash
$ gem install cloudapp --pre
$ cloudapp bookmark http://getcloudapp.com
$ cloudapp upload screenshot.png
$ cloudapp upload --direct screenshot.png
```

For a good time, install `gem-man` and read the man page or
[read it online][man].

[man]: http://cloudapp.github.com/cloudapp


``` bash
$ gem install gem-man
$ gem man cloudapp
```

## Commands

### cloudapp upload `<file>`

Upload `<file>` and print its link to standard out. Use the `--direct` flag to
print the file's direct link which is suitable for use in places that expect a
link to a file like an HTML IMG tag.

``` bash
$ cloudapp upload screenshot.png
http://cl.ly/abc123
```

### cloudapp bookmark `<url>`

Bookmark `<url>` and print its link to standard out.

``` bash
$ cloudapp bookmark http://getcloudapp.com
http://cl.ly/abc123
```

## Wish List

A few simple commands to allow scripting and input from other Unix programs
would be ideal.

 - Share several files: `cloudapp upload *.png`
 - Bookmark several links: `cloudapp bookmark http://douglasadams.com http://zombo.com`
 - Handle bookmarks from STDIN: `pbpaste | cloudapp bookmark`
 - Download a drop: `cloudapp download http://cl.ly/abc123`
 - Encrypt and share a file: `cloudapp upload --encrypt launch_codes.txt`
 - Download and decrypt and encrypted drop: `cloudapp download --key=def456 http://cl.ly/abc123`

There's be a better way to express some of these commands, but you get the
picture.
