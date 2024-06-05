FROM rocker/rstudio:4.0.5

LABEL org.opencontainers.image.source https://github.com/opensafely/research-template

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
    # Install python 3.10. This is the version used by the python-docker
    # image, used for analyses using the OpenSAFELY pipeline.
    --no-install-recommends curl python3.10 python3.10-distutils python3.10-venv \
    # Install dependency for R tidyverse package.
    libxml2 &&\
    # Pip for Python 3.10 isn't included in deadsnakes, so install separately
    curl https://bootstrap.pypa.io/get-pip.py | python3.10 &&\
    # Set default python, so that the Python virtualenv works as expected
    rm /usr/bin/python3 &&\
    ln -s /usr/bin/python3.10 /usr/bin/python3 &&\
    # Create a fake system Python pointing at venv python
    echo 'exec /opt/venv/bin/python3.10 "$@"' > /usr/bin/python &&\
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
COPY --chown=rstudio:rstudio --from=ghcr.io/opensafely-core/r:latest /renv/lib/R-4.0/x86_64-pc-linux-gnu/ /usr/local/lib/R/site-library

# copy in the MOTD file containing the required help text
COPY motd /etc/motd

# Required for installing opensafely cli
ENV PATH="/home/rstudio/.local/bin:${PATH}"

USER rstudio
