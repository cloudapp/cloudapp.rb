# CloudApp Ruby Client

Interact with the [CloudApp API][] from Ruby. Comes with a command line
interface to CloudApp as an added bonus.

[cloudapp api]: http://developer.getcloudapp.com


## Usage

_Usage from Ruby is still a work in progress._


## CLI

Experience all the pleasures of sharing with CloudApp now in your terminal. The
goal of `cloudapp` is to be simple and Unix-friendly.

### Installation

Installation is done via RubyGems: `gem install cloudapp`.

### Usage

 - Bookmark a link: `cloudapp bookmark http://getcloudapp.com`
 - Share a file: `cloudapp upload screenshot.png`
 - List newest drops: `cloudapp list [--count=5]`

### Wish List

Some baseic features that should be added:

 - Download a drop: `cloudapp download http://cl.ly/abc123`
 - List specific columns: `cloudapp list --columns=name,views,link`
 - Handle input from STDIN: `pbpaste | cloudapp bookmark -`

A little more flare would be swell.

 - Share several files: `cloudapp upload *.png`
 - Archive and share several files: `cloudapp upload --archive *.png`
 - Encrypt and share a file: `cloudapp upload --encrypt launch_codes.txt`
 - Download and decrypt and encrypted drop: `cloudapp download http://cl.ly/abc123 def456`

While we're dreaming, what could you do if it kept a local copy of all your
drops? Bonus points for a light weight daemon that kept everything in sync.

 - Find all your screen shots: `cloudapp list /^screen ?shot.*\.png$/`
 - Trash all your stale drops: `cloudapp delete --last-viewed="> 1 month ago"`
 - See your drop views in real time: `cloudapp --tail`

There's bound to be a better way to express some of these commands, but you get
the picture.

### Authentication

As of right now, `cloudapp` makes use of
[`main`'s built-in configuration handling][main-config] to store your CloudApp
credentials **in plain text** at `~/.cloudapp/config.yml`. This file will be
created and opened in your `$EDITOR` the first time it's needed.

[main-config]: https://github.com/ahoward/main/blob/master/README.erb#L220-232

### Harness the Power

Sure you could copy the new drop's link by piping the output to `pbcopy`, but
that's a lot of extra key presses. Instead, try setting this super secret
Cloud.app preference:

```bash
defaults write com.linebreak.CloudAppMacOSX CLUploadShouldCopyExternallyUploadedItems -bool YES
```

Now after restarting Cloud.app, the link to every new drop shared with your
account--even using a tool other than the Mac app--will be copied to your Mac's
clipboard. If you're using the [stand-alone version][stand-alone] of Cloud.app
and not [the Mac App Store version][mas], use the domain
`com.linebreak.CloudAppMacOSXSparkle`.

[stand-alone]: http://getcloudapp.com/download
[mas]:         http://itunes.apple.com/us/app/cloud/id417602904?mt=12&ls=1
