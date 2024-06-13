# 6. Incorporating action image updates

Date: 2024-06-10

## Status

Accepted

## Context

We will be providing a Codespaces environment that supports the most recent versions of the Python and R action images (see [ADR 0005](https://github.com/opensafely-core/research-template-docker/blob/54d0b53b22f257cfa887123b53d4bfad6f9c8533/docs/adr/0005-support-most-recent-action-images.md)). We need to consider how we'll pull in those latest changes and what happens when researchers are still using the older versions.

Note: support of action images only refers to the files we pull in from those images to provide syntax highlighting, help pages/documentation, and autocomplete. It does not affect the use of the `opensafely run` or `opensafely exec` where all versions of action images will be available as they are locally.

## Decision

We will copy in the Python and R libraries directly from the existing action images into our dev container image. We’ll automatically pick up any changes within the existing action images by running the docker image build step weekly (or on demand).

We’ve deferred thinking too much about what happens when new major versions of the action images are released. However, we expect to increment the tag, used to denote a [new version of the dev container Docker image](https://github.com/opensafely/research-template/blob/5bd648f567b52c46a82979dc072d7355b22b2fff/.devcontainer/devcontainer.json#L5), for any backwards incompatible change, i.e:

```
"image": "ghcr.io/opensafely-core/research-template:v0",
```

We’ve otherwise avoided referring to specific versions of Python and R in the .devcontainer config to make future changes easier, as this means we can update the dev container image without needing to change the .devcontainer config.

## Consequences

Automating the build and deploy of updates to the existing action images (Python:v2 and R:latest at the time of writing) means that researchers will get the latest changes whenever they start a new Codespace or rebuild an existing one. It also means there's little-to-no maintenance burden on developers.

Handling major version changes will need more thinking about in future. Our plan to increment the tag on the dev container Docker image means that researchers who are currently using a Codespace won't automatically get an incompatible update, even if they create a new one. However, we will then have to communicate the change and explain how to update to the latest version if/when needed.

Our CI pipeline currently only supports a single major version, so if we were to increment the major version we'd want to think about whether we'd support an older version. e.g if we rolled out a v2 research-template image would we support making any updates to v1, and if so, how?
