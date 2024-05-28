set dotenv-load := true

# list available commands
default:
    @"{{ just_executable() }}" --list

build:
    docker build . -t research-template

test-smoke:
    docker run --rm research-template ls /opt/venv/bin/python3.10

test-packages:
    tests/packages.sh

test-rstudio:
    docker run -i --entrypoint /bin/bash research-template < ./tests/r_studio.sh
