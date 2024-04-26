set dotenv-load := true

# list available commands
default:
    @"{{ just_executable() }}" --list

build:
    docker build .
