# CloudApp CLI

Experience all the pleasures of sharing with [CloudApp][] now in your terminal
and Ruby.

[cloudapp]: http://getcloudapp.com


## Requirements

`cloudapp` requires Ruby 1.9.3 or greater. Windows is not yet supported. If
you're willing to lend a hand, we'd love to officially support it.

### Ubuntu Requirements

A dependency of `cloudapp` requires that libcurl, which can be installed via apt-get.

``` bash
sudo apt-get install libcurl3-dev
```

## Quick Start

``` bash
$ gem install cloudapp
$ cloudapp screenshot.png
$ cloudapp --direct screenshot.png
$ cloudapp http://getcloudapp.com
```

For a good time, install `gem-man` and read the man page or
[read it online][man].

[man]: http://cloudapp.github.com/cloudapp.rb

``` bash
$ gem install gem-man
$ gem man cloudapp
```

## Usage

### `cloudapp [--direct] [--[no-]copy] <file_or_url>...`

Upload a file or share a bookmark. The drop's share link will be printed to
standard output and copied to the system clipboard. Use the `--direct` flag
for the drop's direct link suitable for use in places where a link to a file
is expected. An HTML IMG tag or Campfire, for example.

### Upload a file:

``` bash
$ cloudapp screenshot.png
Uploading screenshot.png... http://cl.ly/image/3U2U2f3B1O0x
```

### Upload several files:

``` bash
$ cloudapp *.png
Uploading screenshot-1.png... http://cl.ly/image/1E1F1k3Q3919
Uploading screenshot-2.png... http://cl.ly/image/3P1s3p0c3545
Uploading screenshot-3.png... http://cl.ly/image/0E3k0h353X0w
```

### Upload file names and URLs from standard input:

``` bash
$ ls *.png | cloudapp
Uploading screenshot-1.png... http://cl.ly/image/1E1F1k3Q3919
Uploading screenshot-2.png... http://cl.ly/image/3P1s3p0c3545
Uploading screenshot-3.png... http://cl.ly/image/0E3k0h353X0w
```

### Bookmark a URL:

``` bash
$ cloudapp http://getcloudapp.com
Bookmarking http://getcloudapp.com... http://cl.ly/352T3Z2G0G2S
```

### Everything at once:

``` bash
$ cloudapp screenshot.png http://getcloudapp.com
Uploading screenshot.png... http://cl.ly/image/3U2U2f3B1O0x
Bookmarking http://getcloudapp.com... http://cl.ly/352T3Z2G0G2S
```

### Copy the drop's direct link:

``` bash
$ cloudapp --direct screenshot.png
Uploading screenshot.png... http://cl.ly/image/3U2U2f3B1O0x/screenshot.png
```

### Print but don't copy the drop's link:

``` bash
$ cloudapp --no-copy screenshot.png
Uploading screenshot.png... http://cl.ly/image/3U2U2f3B1O0x
```


## Wish List

A few simple commands to allow scripting and input from other Unix programs
would be ideal.

 - Download a drop: `cloudapp http://cl.ly/abc123`
 - Encrypt and share a file: `cloudapp --encrypt launch_codes.txt`
 - Download and decrypt and encrypted drop: `cloudapp --key=def456 http://cl.ly/abc123`
