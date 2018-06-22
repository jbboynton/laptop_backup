#!/bin/bash
# Creates a copy of the daily backup every two weeks.

archives_path="/media/james/backups/archives"

remove_outdated() {
  local outdated_backup="$(ls "$archives_path" \
    | grep biweekly \
    | tr -s " " \
    | cut -d " " -f9)"

  rm "$archives_path/$outdated_backup"
}

find_biweekly_backup_path() {
  local daily_backup_path=$1
  local substitution="biweekly"

  echo "${daily_backup_path/daily/$substitution}"
}

create_archive() {
  local daily_backup_filename="$(ls "$archives_path" \
    | grep daily \
    | tr -s " " \
    | cut -d " " -f9)"
  local daily_backup_path="$archives_path/$daily_backup_filename"
  local biweekly_backup_path="$(find_biweekly_backup_path "$daily_backup_path")"

  cp "$daily_backup_path" "$biweekly_backup_path"
}

shutdown_after_backup() {
  /sbin/shutdown -h now
}

remove_outdated
create_archive
shutdown_after_backup

