# 10. Dev container and Codespaces tests

Date: 2024-06-19

## Status

Accepted

## Context

This repository builds a Docker image. The Docker image is used in the dev container configuration in the [research-template](https://github.com/opensafely/research-template) repository. When a codespace is created from a repository based on the research-template, the research-template dev container configuration defines that codespace's environment.

New Docker images are built when changes are merged to `main`, and on a regular automated schedule. Changes to this Docker image may be made directly by maintainers of this repository. Changes may also be made indirectly, by changes to the upstream Docker image or repositories used in the image build. We want to regularly test that the dev container configuration has the expected software installed and that the software functions correctly. This will help to ensure that the research-template configuration continues to function as expected, regardless of the origin of changes to the Docker image.

Such tests depend both on this Docker image and the research-template repository's dev container configuration. However, we do not want to add these tests to the research-template repository: researchers use the research-template repository as a template. If we did add a scheduled GitHub Actions testing workflow to the research-template repository, we would need to ensure that the workflow is removed on repository creation to avoid confusion by researcher users.

While running tests inside a dev container is simple with the [GitHub Action provided by the owners of the Development Containers specification](https://github.com/devcontainers/ci), automating testing in GitHub Codespaces requires starting and cleaning up another separately billable resource. To minimise Codespaces usage, we could use a short idle timeout and retention time for the testing codespace. However, there is still an issue of ensuring that a GitHub bot user has sufficient Codespaces credit to keep the tests running without failure. Because of this, the benefit of adding a Codespaces-based test is not clear at this time; Codespaces-based tests may be less reliable and more difficult to maintain, and not add much more assurance over the simpler process of running tests in a dev container.

## Decision

We will add a test GitHub Actions workflow to this image-building repository. The workflow will not be run as part of the regular continuous integration checks on push or pull request, but only triggered by a cron schedule or a manual interactive run. The test workflow will regularly run the current research-template dev container configuration using the latest published Docker image for this repository, and notify Team REX on any failure.

In that workflow, we will test the basic expected functionality of the dev container on launch, that the expected software is available and can be run. We *will not* test the functionality inside a GitHub codespace created from this dev container.

## Consequences

There is a small risk that there are discrepancies in behaviour between our dev container in the GitHub Actions test environment, and a dev container as launched via GitHub Codespaces. That is, our setup passes the tests when run in the test environment, but has failing behaviour when launched via GitHub Codespaces. If we discover such a problem, we may want to reconsider adding a Codespaces test.
