# CloudApp CLI

Experience all the pleasures of sharing with CloudApp now in your terminal.


## Desired Usage

The goal of `cloudapp` is to be Unix-friendly and handle the following uses:

 - Bookmark a link: `cloudapp bookmark http://getcloudapp.com`
 - Share a file: `cloudapp file screenshot.png`
 - Share several files: `cloudapp file *.png`
 - Archive and share several files: `cloudapp file *.png --archive`
 - Encrypt and share a file: `cloudapp file launch_codes.txt --encrypt`
 - Download and decrypt an encrypted drop: `cloudapp http://cl.ly/abc123 def456`


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
