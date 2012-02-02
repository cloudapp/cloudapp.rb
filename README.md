# CloudApp CLI

Experience all the pleasures of sharing with CloudApp now in your terminal.


## Desired Usage

**These commands don't exist yet. They're just here as a wish list of sorts.**

The goal of `cloudapp` is to be Unix-friendly and handle the following common
use cases:

 - Bookmark a link: `cloudapp new http://getcloudapp.com`
 - Share a file: `cloudapp new screenshot.png`
 - Share several files: `cloudapp new *.png`
 - Archive and share several files: `cloudapp new --archive *.png`
 - Download a drop: `cloudapp download http://cl.ly/abc123`

Ultimately, a little more flare would be swell.

 - Share everything at once: `cloudapp new http://google.com *.png http://bing.com`
 - Encrypt and share a file: `cloudapp new --encrypt launch_codes.txt`
 - Download and decrypt and encrypted drop: `cloudapp download http://cl.ly/abc123 def456`

While we're dreaming, what could you do if it kept a local copy of all your
drops?

 - List newest drops: `cloudapp list --top=5`
 - Find all your screen shots: `cloudapp list /^screen ?shot.*\.png$/`
 - Trash all your stale drops: `cloudapp delete --last-viewed="> 1 month ago"`
 - See your drop views in real time: `cloudapp --tail`

There's bound to be a better way to express some of these commands, but you get
the picture.


## Authentication

As of right now, `cloudapp` makes use of
[`main`'s built-in configuration handling][main-config] to store your CloudApp
credentials **in plain text** at `~/.cloudapp/config.yml`.


[main-config]: https://github.com/ahoward/main/blob/master/README.erb#L220-232


## Harness the Power

Sure you could copy the new drop's link by piping the output to `pbcopy`, but
that's a lot of extra key presses. Instead, try setting this super secret
Cloud.app preference:

```bash
defaults write com.linebreak.CloudAppMacOSX CLUploadShouldCopyExternallyUploadedItems -bool YES
```

Now the link to every new drop shared with your account--even using a tool other
than the Mac app--will be copied to your Mac's clipboard. If you're using the
[stand-alone version][stand-alone] of Cloud.app and not
[the Mac App Store version][mas], use the domain
`com.linebreak.CloudAppMacOSXSparkle`.

[stand-alone]: http://getcloudapp.com/download
[mas]:         http://itunes.apple.com/us/app/cloud/id417602904?mt=12&ls=1
