set dotenv-load := true

# list available commands
default:
    @"{{ just_executable() }}" --list

build:
    docker build . -t research-template

check-image-exists:
    # Extra brackets are for Just escaping.
    docker image inspect --format='{{{{.Id}}}}' research-template

test-packages: check-image-exists
    tests/packages.sh

test-python-install: check-image-exists
    docker run -i --entrypoint /bin/bash research-template < ./tests/python.sh

test-rstudio-install: check-image-exists
    docker run -i --entrypoint /bin/bash research-template < ./tests/r_studio.sh
