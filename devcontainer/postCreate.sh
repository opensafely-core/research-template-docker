#!/bin/bash

set -euo pipefail

/usr/local/bin/pip3 install --user -r /opt/devcontainer/requirements.in

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

#download and extract latest ehrql source
wget https://github.com/opensafely-core/ehrql/archive/main.zip -P .devcontainer
unzip -o .devcontainer/main.zip -d .devcontainer/
rm .devcontainer/main.zip
