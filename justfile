set dotenv-load := true

# list available commands
default:
    @"{{ just_executable() }}" --list

build:
    #!/usr/bin/env bash
    set -euo pipefail

    export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    export GITREF=$(git rev-parse --short HEAD)

    docker build . --platform linux/amd64 --build-arg BUILD_DATE="$BUILD_DATE" --build-arg GITREF="$GITREF" -t research-template-r-v1
    docker build . --platform linux/amd64 --build-arg BUILD_DATE="$BUILD_DATE" --build-arg GITREF="$GITREF" --build-arg R_SITE_LIBRARY_SOURCE=/usr/local/lib/R/site-library/ --build-arg R_IMAGE_VERSION=v2 -t research-template-r-v2

check-image-exists-v1:
    # Extra brackets are for Just escaping.
    docker image inspect --format='{{{{.Id}}' research-template-r-v1

check-image-exists-v2:
    # Extra brackets are for Just escaping.
    docker image inspect --format='{{{{.Id}}' research-template-r-v2

test-packages-v1: check-image-exists-v1
    tests/packages-v1.sh

test-packages-v2: check-image-exists-v2
    tests/packages-v2.sh

test-python-install-v1: check-image-exists-v1
    docker run -i --rm --entrypoint /bin/bash research-template-r-v1 < ./tests/python.sh

test-rstudio-install-v1: check-image-exists-v1
    docker run -i --rm --entrypoint /bin/bash research-template-r-v1 < ./tests/r_studio.sh

test-postcreate-script-v1: check-image-exists-v1
    docker run -i --rm --entrypoint /bin/bash research-template-r-v1 < ./tests/postCreate.sh

test-python-install-v2: check-image-exists-v2
    docker run -i --rm --entrypoint /bin/bash research-template-r-v2 < ./tests/python.sh

test-rstudio-install-v2: check-image-exists-v2
    docker run -i --rm --entrypoint /bin/bash research-template-r-v2 < ./tests/r_studio.sh

test-postcreate-script-v2: check-image-exists-v2
    docker run -i --rm --entrypoint /bin/bash research-template-r-v2 < ./tests/postCreate.sh
