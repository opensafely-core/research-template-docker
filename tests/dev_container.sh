#!/bin/bash
set -euxo pipefail

# Check the OpenSAFELY research-template example runs.
opensafely run run_all

# Check the RStudio server is running.
curl -L 'http://localhost:8787' | grep 'RStudio'
