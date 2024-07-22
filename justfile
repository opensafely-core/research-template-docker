set dotenv-load := true

# list available commands
default:
    @"{{ just_executable() }}" --list

build:
    #!/usr/bin/env bash
    set -euo pipefail

    export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    docker build . --build-arg BUILD_DATE="$BUILD_DATE" --build-arg GITREF="$GITREF" -t research-template

check-image-exists:
    # Extra brackets are for Just escaping.
    docker image inspect --format='{{{{.Id}}}}' research-template

test-packages: check-image-exists
    tests/packages.sh

test-python-install: check-image-exists
    docker run -i --rm --entrypoint /bin/bash research-template < ./tests/python.sh

test-rstudio-install: check-image-exists
    docker run -i --rm --entrypoint /bin/bash research-template < ./tests/r_studio.sh

test-postcreate-script: check-image-exists
    docker run -i --rm --entrypoint /bin/bash research-template < ./tests/postCreate.sh
