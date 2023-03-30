#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
desination_path="/mnt/mirror/repos"

####################
# Mirror
####################
# github desktop
"$HOME/git/desktop-makerepo/build.zsh" >> "$HOME/logs/desktop-makerepo.log"
# rclone
"$HOME/git/rclone-makerepo/build.zsh" >> "$HOME/logs/rclone-makerepo.log"
# rstudio and zoom
"$HOME/git/my/update.zsh" >> "$HOME/logs/my-update.log"

####################
# Deploy
####################
"$SCRIPT_DIR/tools/deploy.sh" "$desination_path"
