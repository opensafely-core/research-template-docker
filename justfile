set dotenv-load := true

# List available commands.
default:
    @just --list

# Shared Docker configuration.
docker := 'docker run --rm --cap-drop ALL'

# Restricted container.
docker_safe := docker + ' --network none --read-only --security-opt no-new-privileges:true --user 65534:65534'

# Allow sudo with the minimum capabilities required by each test.
docker_sudo := docker + ' --user rstudio --cap-add SETUID --cap-add SETGID --cap-add CHOWN --cap-add DAC_OVERRIDE --cap-add AUDIT_WRITE'

# RStudio requires localhost access but no external network.
docker_rstudio := docker_sudo + ' --network none --hostname rstudio-test --add-host rstudio-test:127.0.0.1'

# Post-create requires network access and additional filesystem permissions.
docker_postcreate := docker_sudo + ' --cap-add FOWNER'

build:
    #!/usr/bin/env bash
    set -euo pipefail

    export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    docker build . --platform linux/amd64 --build-arg BUILD_DATE="$BUILD_DATE" --build-arg GITREF="$GITREF" -t research-template

check-image-exists:
    docker image inspect --format='{{{{.Id}}' research-template

test-packages: check-image-exists
    tests/packages.sh

test-python-install: check-image-exists
    {{docker_safe}} -i --entrypoint /bin/bash research-template < ./tests/python.sh

test-rstudio-install: check-image-exists
    {{docker_rstudio}} -i --entrypoint /bin/bash research-template < ./tests/r_studio.sh

test-postcreate-script: check-image-exists
    {{docker_postcreate}} -i --entrypoint /bin/bash research-template < ./tests/postCreate.sh