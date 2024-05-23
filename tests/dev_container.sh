#!/bin/bash
set -euxo pipefail

# Check that we are the rstudio user.
[ "$(whoami)" == 'rstudio' ]

# Check the OpenSAFELY research-template example runs.
opensafely run run_all

# Check the RStudio server is running.
curl -L 'http://localhost:8787' | grep 'RStudio'

# Check the RStudio server installation.
sudo rstudio-server stop
sudo rstudio-server verify-installation
