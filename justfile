set dotenv-load := true

# list available commands
default:
    @"{{ just_executable() }}" --list

build:
    docker build .

smoke-test:
    docker run --rm research-template ls /opt/venv/bin/python3.10