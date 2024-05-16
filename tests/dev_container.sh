#!/bin/bash
set -euxo pipefail

# Check that we are the rstudio user.
[ "$(whoami)" == 'rstudio' ]

# Check the OpenSAFELY research-template example runs.
opensafely run run_all

# Check that the Python packages in the OpenSAFELY Python image are available in the dev container.
# This checks package names and versions.
python_image_version='v2'
opensafely pull "python:$python_image_version"

docker_python_packages=$(docker run "ghcr.io/opensafely-core/python:$python_image_version" python -m pip freeze)
local_python_packages=$(/opt/venv/bin/python3.10 -m pip freeze)
diff <(echo "$local_python_packages") <(echo "$docker_python_packages")

# Check the RStudio server is running.
curl -L 'http://localhost:8787' | grep 'RStudio'

# Check the RStudio server installation.
sudo rstudio-server stop
sudo rstudio-server verify-installation
