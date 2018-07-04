# Laptop Backup

Creates daily and biweekly backups when needed.

## Usage

### 1. Create cron jobs

Create new cron jobs to run the daily and biweekly backup scripts.
These jobs will need to run as root in order to access removable
storage devices, perform system shutdown, etc.

```
0 3 * * * /home/james/bin/laptop_backup/src/daily_backup.sh > /dev/null 2>&1
30 4 1,15 * * /home/james/bin/laptop_backup/src/biweekly_backup.sh > /dev/null 2>&1
```

### 2. Record the last time you logged in

If you haven't logged in since *before* the most recent backup was created,
there's a good chance you won't have anything new to back up. To prevent
unnecessary backups, run the `record_last_login.sh` script when you log in. This
script records the timestamp of your last login, so that it can be compared to
the timestamp of your last backup before a backup is made. If you've logged in
since the last backup was made, the script presumes that something worth backing
up may have found its way into your system while you were logged in, and
performs the backup.

