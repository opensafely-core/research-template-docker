# 1. Purpose of research-template-docker

Date: 2024-06-04

## Status

Accepted

## Context

We are using [dev containers](https://code.visualstudio.com/docs/devcontainers/create-dev-container) to provide a configuration for Codespaces that gives researchers a useful development environment to use while working on their OpenSAFELY projects. We have created a custom Docker image for this dev container environment and have decided to reference the built image in the dev container configuration rather than let researchers build from the Dockerfile themselves.

The custom image is quite large and takes a while to build, which extends the start up time of the Codespace. Additionally, we encountered frequent timeout errors when building the image (these were known issues). Building the Docker image upfront removes these issues.

This custom pre-built image requires a Dockerfile and other supporting files to be created.

## Decision

We will create a separate GitHub repo to store the Dockerfile and other supporting files. Specifically, we will store the following in the research-template-docker repo:

* The Dockerfile used to generate the dev container's Docker image
* The tooling and GitHub actions to build the Docker image and to run the tests
* Some of the supporting files for the dev container configuration in the research-template (e.g documentation and ADRs).

The research-template repo will only contain the code and configuration to be copied into a researcher’s repo.

## Consequences

By storing these files in a separate repo we will be creating a good separation of concerns between the research code that will be used to help researchers get started on OpenSAFELY and the supporting infrastructure. The researchers who base their work on the research-template repo will have a copy of the things they need to get started and nothing else. They won't have access to any of the additional supporting infrastructure and will not even need to be aware that the supporting infrastructure exists. This reduces their cognitive load. The supporting infrastructure will be controlled and updated by developers working in the opensafely-core GitHub organisation.

Using a separate repo does add some additional complexity for developers, who need to be aware of the different purposes of the two repos, but we believe that having appropriate documentation will ameliorate this. 

Storing the repo in a separate organisation also allows us to apply different security settings to the repo and to more easily setup Dependabot.
