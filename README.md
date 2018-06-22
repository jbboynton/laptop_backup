# Laptop Backup

Creates daily and biweekly backups when needed.

## Usage

Create new cron jobs to run the daily and biweekly backup scripts.
These jobs will need to run as root in order to access removable
storage devices, perform system shutdown, etc.

```
0 3 * * * /home/james/bin/laptop_backup/src/daily_backup.sh > /dev/null 2>&1
30 4 1,15 * * /home/james/bin/laptop_backup/src/biweekly_backup.sh > /dev/null 2>&1
```

