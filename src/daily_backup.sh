#!/bin/bash
# Creates a backup of the system if needed.

last_backup_path="/home/james/.last_backup"
archives_path="/media/james/backups/archives"

backup_is_needed() {
  local backup_needed

  backup_needed=0

  if no_usage; then
    backup_needed=1
  fi

  return "$backup_needed"
}

no_usage() {
  local backup_needed
  local last_usage

  backup_needed=0

  last_backup="$(time_since_last_backup)"
  last_usage="$(time_since_last_usage)"

  if [ "$last_usage" -gt "$last_backup" ]; then
    backup_needed=1
  fi

  return "$backup_needed"
}

time_since_last_backup() {
  local last_backup="$(time_of_last_backup)"
  local time_now="$(date +%s)"
  local time_since_backup=$((time_now - last_backup))

  echo "$time_since_backup"
}

time_of_last_backup() {
  local last_backup="$(sed -n 1p "$last_backup_path" 2> /dev/null)"
  local end_of_time=2147483647

  case "$last_backup" in
    [0-9]* ) last_backup_time="$last_backup" ;;
    *      ) last_backup_time="$end_of_time" ;;
  esac

  echo "$last_backup_time"
}

time_since_last_usage() {
  local last_usage_in_ms="$(xprintidle)"
  local last_usage_in_sec="$((last_usage_in_ms / 1000))"

  echo "$last_usage_in_sec"
}

remove_outdated() {
  local outdated_backup="$(ls "$archives_path" \
    | grep daily \
    | tr -s " " \
    | cut -d " " -f9)"

  rm "$archives_path/$outdated_backup"
}

create_archive() {
  local time_of_backup="$(date +%Y-%m-%d_%s)"
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
  echo "$(date +%s)" > "$last_backup_path"
}

if backup_is_needed; then
  remove_outdated
  create_archive
  record_time_of_backup
fi

