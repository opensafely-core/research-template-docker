FROM rocker/rstudio:4.0.5

LABEL org.opencontainers.image.title="Research Template" \
      org.opencontainers.image.description="Dev container image for the OpenSAFELY research template" \
      org.opencontainers.image.source="https://github.com/opensafely-core/research-template-docker" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.authors="OpenSAFELY Team <team@opensafely.org>" \
      org.opencontainers.image.vendor="OpenSAFELY"

# we are going to use an apt cache on the host, so disable the default debian
# docker clean up that deletes that cache on every apt install
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# DL3008: we always want latest package versions when we rebuild
# DL3009: we are caching apt
# hadolint ignore=DL3008,DL3009
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    echo "deb http://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu focal main" > /etc/apt/sources.list.d/deadsnakes-ppa.list &&\
    /usr/lib/apt/apt-helper download-file 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf23c5a6cf475977595c89f51ba6932366a755776' /etc/apt/trusted.gpg.d/deadsnakes.asc &&\
    apt-get update &&\
    apt-get install -y \
    # Install a command-line editor for working with Git.
    nano \
    # Install python 3.10. This is the version used by the python-docker
    # image, used for analyses using the OpenSAFELY pipeline.
    --no-install-recommends curl software-properties-common ca-certificates gnupg lsb-release apt-transport-https dirmngr \
    # Install dependencies for R tidyverse, knitr, and dagitty packages.
    libxml2 libmagick++-6.q16-8 libnode-dev &&\
    # expose the copied venv python as system python3 via alternatives
    if [ -x /opt/venv/bin/python3.10 ]; then \
      update-alternatives --install /usr/bin/python3 python3 /opt/venv/bin/python3.10 2 || true; \
    fi; \
    # make /usr/bin/python call the venv python
    printf '%s\n' 'exec /opt/venv/bin/python3.10 "$@"' > /usr/bin/python; chmod +x /usr/bin/python; \
    # Activate the venv in every terminal
    echo "source /opt/venv/bin/activate" >> /home/rstudio/.bashrc &&\
    # Print the MOTD/help text in every shell
    echo "cat /etc/motd" >> /home/rstudio/.bashrc &&\
    # Configure RStudio Server to run without auth
    echo "auth-none=1" >> /etc/rstudio/rserver.conf &&\
    echo "USER=rstudio" >> /etc/environment &&\
    # Give the local user sudo (aka root) permissions
    usermod -aG sudo rstudio &&\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy the Python virtualenv from OpenSAFELY Python action image
#
# DL3022: hadolint can't access a network and doesn't behave
# as expected when a reference is made to an external image.
# hadolint ignore=DL3022
COPY --chown=rstudio:rstudio --from=ghcr.io/opensafely-core/python:v2 /opt/venv /opt/venv

# copy the renv directory into the local site library from the OpenSAFELY R action image
#
# DL3022: hadolint can't access a network and doesn't behave
# as expected when a reference is made to an external image.
# hadolint ignore=DL3022
COPY --chown=rstudio:rstudio --from=ghcr.io/opensafely-core/r:v1 /renv/lib/R-4.0/x86_64-pc-linux-gnu/ /usr/local/lib/R/site-library

# copy in the MOTD file containing the required help text
COPY motd /etc/motd

# Copy in auxiliary dev container files.
# These reside in this repository
# to minimise the dev container configuration in the research-template repository.
COPY devcontainer/ /opt/devcontainer/

ENV \
    # Required for installing opensafely cli
    PATH="/home/rstudio/.local/bin:${PATH}" \
    # Required to make Git features such as rebasing work.
    EDITOR="nano"

# The following build details will change.
# These are the last step to make better use of Docker's build cache,
# avoiding rebuilding image layers unnecessarily.
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.created=$BUILD_DATE
ARG GITREF=unknown
LABEL org.opencontainers.image.revision=$GITREF

USER rstudio
