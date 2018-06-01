Postfix Relay Guide
===================
I have been looking for a simple guide to setting up
[postfix](http://www.postfix.org/) as a local email proxy for a home server.

It took me 5 guides and several google searches to get it working in the end.
There is also some confusion as to TLS support from postfix: even the official
AWS guide does not use the built-in TLS support in favour of stunnel.


Disclamer
---------
Email server setup is not a simple task as they are easly abused.
All email software and services take precautions to make sure only allowed
servers can send or accept emails.

This guide aims at setting up a limited access relay:

  * Only the local host can send emails through the relay.
  * The server does not send emails itself but relays them to an extenral service.

In addition here is the standard security warning: copy-pasting configurations from
the internet is not a good idea.
While I did my best to describe a simple yet secure configuration I have not
looked through all the available configuration options and I am not a security expert.


Steps
-----
Here are the steps to get postfix relaying through SES.
My sugesstion is to follow this steps manually (hint: kitchen-vagrant) and
then automate the configuration with your tool of choice (hint: ansible ;-) ).

### Environment

  * OS: Fedora Server 26 (64-bits).
  * Sendmail/postfix: nothing installed on fresh installation.
  * Email service: AWS Simple Email Service (SES) in sandbox mode.

### Packages
There are three packages you will need:
```bash
sudo dnf install postfix cyrus-sasl cyrus-sasl-plain
```

The `cyrus-sasl` and `cyrus-sasl-plain` are required for postfix to use the
username and password we will configure later.

Without these, postfix will fail to authenticate with SES and log errors like:
```
SASL authentication failure: No worthy mechs found
```

### Configuration
You can either replace the entire configuration file or edit the default.
I prefer to edit the default when it comes to comments so below is a diff
of what I added.

```diff
$ diff /etc/postfix/main.cf main.default.cf
119d118
< myorigin = <MY_DNS_NAME>
271c270
< mynetworks_style = host
---
> #mynetworks_style = host
317d315
< relay_domains =
339,346d336
< relayhost = [email-smtp.SES_SUPPORTED_REGION.amazonaws.com]:465
< smtp_use_tls = yes
< smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
< smtp_tls_security_level = secure
< smtp_tls_wrappermode = yes
< smtp_sasl_auth_enable = yes
< smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
< smtp_sasl_security_options = noanonymous
```

### User Authentication with the relay
For SES to accept the emails from the relay, postfix needs to authenticate
with a valid username and password.

We do this by creating `/etc/postfix/sasl_passwd` and storing the servers
ans users to access them:
```text
[email-smtp.SES_SUPPORTED_REGION.amazonaws.com]:465 USERNAME:PASSWORD
```

Once this file is created/updated we use it to generate a password DB
and we secure the both of them so postfix can use these details:
```bash
sudo vim /etc/postfix/sasl_passwd
# Edit as above ...
sudo postmap hash:/etc/postfix/sasl_passwd
sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

# You can finally load the new configuration!
sudo systemctl restart postfix
```

### Testing
You should be able to send emails through your relay now:
```bash
cat > /tmp/test.email << EOM
From: test@MY_DNS_NAME
Subject: Test
This email was sent from Amazon SES using Postfix.
.
EOM
cat /tmp/test.email | sendmail -f test@MY_DNS_NAME me@address.com
```

Or with a shorter command:
```bash
mail -s "Test Email $(date)" <me@address.com> <<< "This is a test email."
```

Check the destination email and logs to verify it all works!

### CronJob email support
First install a test with crontab:
```
MAILTO=me@address.com
*/15 * * * * echo 'Test from cron'
```

TODO: can't get the /etc/aliases to be picked up.


References
----------
On top of lots of googling for errors and postfix commands (`postqueue -f`
can be used to retry test emails when they fail) I was able to setup a
working postfix relay server with SES and TLS thanks to:

  * http://www.postfix.org/BASIC_CONFIGURATION_README.html
  * http://www.tothenew.com/blog/configuring-server-to-relay-email-through-amazon-ses/
  * http://docs.aws.amazon.com/ses/latest/DeveloperGuide/postfix.html
  * http://www.postfix.org/TLS_README.html
  * https://robpol86.com/postfix_gmail_forwarding.html
