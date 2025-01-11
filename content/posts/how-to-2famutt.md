+++
date = '2025-01-11'
title = 'Neomutt and Outlook'
tags = ['howto', 'tutorial', 'mutt', '2fa', 'oauth2']
categories = ['technical']
+++
Neomutt is a great way to read, send and manage your email.
In this tutorial we will configure neomutt to be able to synchronize e-mails with Outlook (or other popular e-mail provider) addresses!
By the end of this tutorial, you will be able to manually synchronize your emails using the `mailsync` command and read/manage your emails in an interface that looks like so:

{{< centered image="/neomutt-screenshot.png" >}}

Apologies for the blur, but I dont want you to read **my** e-mails.

## First Things First
First, sign in to your mail through the browser. This is needed for the OAuth2 authorization flow.

You should also obviously install neomutt.
This can just be done through your package manager.
As I am using Arch linux, I will do so using `pacman`, but on Ubuntu or Debian you should use `apt`:

```sh
pacman -S neomutt
```

## GPG
The first thing you'll need is a `gpg` key for encryption purposes.
You can check your keys using `gpg --list-keys`.
If you don't already have a `gpg` key, you can generate one with the `--full-gen-key` flag.

```sh
gpg --full-gen-key
```

## OAuth2
As part of installing neomutt, you should have the oauth2 python script located in `/usr/share/neomutt/oauth2/`.
We need to register neomutt as an already trusted app.
We will simply abuse the thunderbird client-id for this, which is: `9e5f94bc-e8a4-4e73-b8be-63364c29d753` - with this you don't need to specify a client secret:

```sh
/usr/share/neomutt/oauth2/mutt_oauth2.py \
    -v \
    -t \
    --authorize \
    --client-id "9e5f94bc-e8a4-4e73-b8be-63364c29d753" \
    --client-secret "" \
    --email "your-email-here" \
    --provider microsoft \
    $HOME/email-token
```

This will ask you a couple questions.
Select `authcode` for the preferred OAuth2 flow.
If prompted for a client secret, simply press enter.
You should get a link - enter that link into your browser and allow the app.
By the end of the flow you should end up at an empty website.
Copy the last part of the URL and paste it into your terminal.
After this you should have a token file located at `$HOME/email-token`.
It's a good idea to take a backup of this file just in case you overwrite it.
But if you do loose it, you can just run the flow again.

## Mutt-Wizard
We are almost there!
The wonderful Luke Smith has made a neat setup wizard called [mutt-wizard](https://muttwizard.com/).
Install (see the mutt-wizard website), run it and enter your email information.
After this, you should edit your `~/.mbsyncrc` file, as the default `PassCmd` is not quite configured yet.
It should look something like this (make sure to change `your-email-here` and `username` to the appropriate values):

```
...
PassCmd "/usr/share/neomutt/oauth2/mutt_oauth2.py --encryption-pipe 'gpg -e -r your-email-here' /home/username/email-token"
...
```

You should now be able to run `mailsync` (installed with mutt-wizard):

```sh
mailsync
```

It might ask you to select which profile to sync.
Just provide the name you set when setting up your gpg profile and everything should sync now!
After a successful sync, you should be able to just open `neomutt` and start reading, replying and whatever you do with email!

```sh
neomutt
```

{{< centered image="/6616144.png" >}}
