#!/bin/bash
# Records the time of last login.

record_time_of_last_login() {
  local config_directory="/home/james/.laptop_backup"
  local last_login_path="/home/james/.laptop_backup/last_login"

  if [ ! -d "$config_directory" ]; then
    mkdir "$config_directory"
  fi

  date +%s > "$last_login_path"
}

record_time_of_last_login
