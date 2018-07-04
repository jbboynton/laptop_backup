#!/bin/bash
# Creates a backup of the system if needed.

last_backup_path="/home/james/.laptop_backup/last_backup"
last_login_path="/home/james/.laptop_backup/last_login"
archives_path="/media/james/backups/archives"
time_of_backup="$(date +%Y-%m-%d_%s)"

backup_is_needed() {
  local backup_needed
  local last_usage

  # Default: 0 (true)
  backup_needed=0

  last_backup="$(time_of_last "$last_backup_path")"
  last_login="$(time_of_last "$last_login_path")"

  if [ "$last_backup" -gt "$last_login" ]; then
    backup_needed=1
  fi

  log "$backup_needed" "$last_usage" "$last_backup"

  return "$backup_needed"
}

time_of_last() {
  local path_to_timestamp="$1"
  local timestamp="$(sed -n 1p "$path_to_timestamp" 2> /dev/null)"
  local end_of_time=2147483647

  case "$timestamp" in
    [0-9]* ) last_time="$timestamp" ;;
    *      ) last_time="$end_of_time" ;;
  esac

  echo "$last_time"
}

log() {
  local backup_indicator="$1"
	local last_usage="$2"
  local last_backup="$3"
  local log_file="/home/james/bin/laptop_backup/logs/daily.log"
  local is_needed
  local info

  if [ "$backup_indicator" -eq 1 ]; then
    info="Last usage is greater than last backup! (Laptop hasn't been used "
    info+="since last backup.)"
    is_needed="false"
  else
    info="Last backup is greater than last usage! (Laptop used since last "
    info+="backup.)"
    is_needed="true"
  fi

	read -r -d "" log_entry << EOM

+----------------------------------+
|                                  |
| Daily Backup                     |
| Timestamp: $time_of_backup |
|                                  |
+----------------------------------+

Last usage:    $last_usage
Last backup:   $last_backup
Backup needed: $is_needed
Info:          $info

+----------------------------------+

EOM

  echo "$log_entry" >> "$log_file"
}

remove_outdated() {
  local outdated_backup="$(ls "$archives_path" \
    | grep daily \
    | tr -s " " \
    | cut -d " " -f9)"

  rm "$archives_path/$outdated_backup"
}

create_archive() {
  local archive_filename="${time_of_backup}_daily.tar.gz"

  local exclusions=(
    "--exclude=/cdrom"
    "--exclude=/dev"
    "--exclude=/home/james/Downloads"
    "--exclude=/home/james/VirtualBox VMs"
    "--exclude=/lost+found"
    "--exclude=/media"
    "--exclude=/mnt"
    "--exclude=/proc"
    "--exclude=/run"
    "--exclude=/sys"
    "--exclude=/tmp"
  )

  sudo tar -cpzf "${archives_path}/${archive_filename}" "${exclusions[@]}" /
}

record_time_of_backup() {
  local config_directory="/home/james/.laptop_backup"

  if [ ! -d "$config_directory" ]; then
    mkdir "$config_directory"
  fi

  date +%s > "$last_backup_path"
}

if backup_is_needed; then
  remove_outdated
  create_archive
  record_time_of_backup
fi

