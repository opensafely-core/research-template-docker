#!/bin/bash
set -eu
test -f project.yaml || exit
images=$(opensafely info --list-project-images | sort | uniq)
if [[ "$images" =~ "r:v2" ]]; then
    opensafely launch rstudio:v2 --port 8787 --background --no-browser
else
    opensafely launch rstudio:v1 --port 8787 --background --no-browser
fi
