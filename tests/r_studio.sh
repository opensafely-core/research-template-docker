#!/bin/bash
set -euxo pipefail

# Check that we are the rstudio user.
[ "$(whoami)" == 'rstudio' ]

# Check the RStudio server installation.
sudo rstudio-server verify-installation
sudo rstudio-server start

# Check the RStudio server is running.
curl -L 'http://localhost:8787' | grep 'RStudio'

sudo rstudio-server stop
