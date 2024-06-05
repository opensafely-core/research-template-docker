# 4. Single dev container configuration

Date: 2024-06-05

## Status

Accepted

## Context

We now have a custom dev container Docker image. We want to build on this to provide a more "habitable" environment for researchers in which to write code. This includes having the same Python and R packages available within the development environment as they would find in the action images. This will give researchers syntax highlighting, help pages/documentation, and autocomplete.

## Decision

We will continue to have a single dev container configuration that allows researchers to create one type of Codespace containing everything they need to write code for the OpenSAFELY platform.

We will copy relevant files into the custom Docker image, such as the Python and R packages from the OpenSAFELY [Python](https://github.com/opensafely-core/python-docker) and [R](https://github.com/opensafely-core/r-docker) action images.

## Consequences

We could provide two separate dev container configurations, one mirroring the Python action image and one mirroring the R action image. Although, both would need to support ehrQL development. However:

* This was too confusing for users as the UI for choosing Codespaces configs is not intuitive.
* Having to maintain and develop two or more different configurations would have added significant complexity.
* Providing updates to the dev container configurations would be more complex, either for developers or researchers (or both).

We believe that having a single development environment will be easier for researchers and developers. Researchers will expect to have a single development environment and won't expect to switch between two different ones. It will also be easier for researchers to get started as they can click the "Open in a Codespace" button in GitHub and have access to everything they need.
