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
    apt-get update &&\
    apt-get install -y \
    # Install a command-line editor for working with Git.
    nano \
    --no-install-recommends curl \
    # Install dependencies for R tidyverse, knitr, and dagitty packages.
    libxml2 libmagick++-6.q16-8 libnode-dev

ARG UV_PLATFORM=uv-x86_64-unknown-linux-gnu.tar.gz

# hadolint ignore=DL3008
RUN set -eux; \
    # Fetch uv from GitHub Releases
    curl -fSL "https://github.com/astral-sh/uv/releases/latest/download/${UV_PLATFORM}" -o /tmp/${UV_PLATFORM}; \
    mkdir -p /tmp/uv-extract && tar -xzf /tmp/${UV_PLATFORM} --strip-components=1 -C /tmp/uv-extract; \
    install -m 0755 /tmp/uv-extract/uv /usr/local/bin/uv; \
    rm -rf /tmp/uv-extract; \
    # Use uv to install Python 3.10.
    # Python 3.10 is the version used by the python-docker
    # v2 image, used for analyses using the OpenSAFELY pipeline.
    /usr/local/bin/uv python install 3.10 --install-dir /opt/uv-python --default; \
    # Create default python symlinks…
    /usr/local/bin/uv python update-shell; \
    # … and move them to be accessible to all users.
    rm -f /usr/bin/python3 && mv /root/.local/bin/python3* /usr/bin/; \
    echo 'exec /opt/venv/bin/python3.10 "$@"' > /usr/bin/python && chmod +x /usr/bin/python; \
    # pip isn't included, so install separately
    curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py; \
    python3.10 /tmp/get-pip.py --break-system-packages; \
    # Create a system virtualenv at /opt/venv,
    /usr/bin/python3 -m venv /opt/venv; \
    # Activate the venv in every terminal.
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
