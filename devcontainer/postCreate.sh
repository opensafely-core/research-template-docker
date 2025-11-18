#!/bin/bash

set -euo pipefail

# We have to specify the Python version,
# otherwise uv tries to inspect /usr/bin/python
# and fails because this is a shell script we've added.
uv tool install --python 3.10 opensafely

#set R working directory
! grep -q "$1" $R_HOME/etc/Rprofile.site && sudo tee -a $R_HOME/etc/Rprofile.site <<< "setwd(\"$1\")"
#set RStudio working directory
set_rstudio_pref() {
    key="$1"
    value="$2"
    orig_prefs=$(jq -ne "input ? // {}" < ~/.config/rstudio/rstudio-prefs.json)
    new_prefs=$(jq "if has(\"$key\") then . else . + {\"$key\": $value} end" <<< "$orig_prefs")
    echo "$new_prefs" > ~/.config/rstudio/rstudio-prefs.json
}

#set RStudio working directory
set_rstudio_pref "initial_working_directory" "\"$1\""

#turn on RStudio autosave
set_rstudio_pref "auto_save_on_blur" "true"
set_rstudio_pref "auto_save_on_idle" "\"commit\""

#download and extract latest ehrql source
wget https://github.com/opensafely-core/ehrql/archive/main.zip -P .devcontainer
unzip -o .devcontainer/main.zip -d .devcontainer/
rm .devcontainer/main.zip
