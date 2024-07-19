#!/bin/bash
set -euxo pipefail

# postCreate script requirements
cd ~
mkdir .devcontainer
mkdir -p /tmp/testdir
sudo apt-get -qq update && sudo apt-get install -qq -y jq;

# run postcreate script
. /opt/devcontainer/postCreate.sh "/tmp/testdir"

# check opensafely CLI installed
opensafely --version

# check R working directory
[ "$(Rscript -e 'getwd()')" == '[1] "/tmp/testdir"' ]

# check Rstudio working directory
[ "$(jq '.initial_working_directory' < ~/.config/rstudio/rstudio-prefs.json )" == '"/tmp/testdir"' ]

# check preexisting Rstudio preference
[ "$(jq '.posix_terminal_shell' < ~/.config/rstudio/rstudio-prefs.json )" == '"bash"' ]

# check ehrql source present
[ -d .devcontainer/ehrql-main ]

# check ehrql zip file removed
[ ! -f .devcontainer/main.zip ]
