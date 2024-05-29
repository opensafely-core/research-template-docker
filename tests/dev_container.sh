#!/bin/bash
set -euxo pipefail

# Check the OpenSAFELY research-template example runs.
opensafely run run_all

# Check the RStudio server is running.
curl -L 'http://localhost:8787' | grep 'RStudio'

# This is a rudimentary placeholder test of the ehrQL installation.
# We cannot easily run ehrQL because it requires Python 3.11 to be imported,
# but the OpenSAFELY Python Docker image, and the dev container, uses Python 3.10.
# In future, we could actually try and import ehrQL through Python.
ls .devcontainer/ehrql-main/
