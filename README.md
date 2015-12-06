# ip-notifier
Polls server and sends email notification upon external IP address change. Currently works with Gmail for outgoing mail.

Setup
---

Create config file:

In ~/.ipnotifierconfig:
```json
{
  "previous_ip": "",
  "destination_email_address": "XXX",
  "source_email_address": "XXX",
  "outgoing_mail_domain": "smtp.gmail.com",
  "mail_username": "XXX",
  "mail_password": "XXX"
}
```

Make ipnotifier executable
```bash
chmod a+x ipnotifier.rb
```

Schedule in cron. Run the following command: 
```bash
crontab -e
```

In the editor:
```cron
* * * * * /path/to/ipnotifier.rb > /dev/null 2>&1
```

