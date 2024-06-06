# 3. The research-template's .devcontainer directory

Date: 2024-06-04

## Status

Accepted

## Context

We are using [dev containers](https://code.visualstudio.com/docs/devcontainers/create-dev-container) to provide a configuration for Codespaces that gives researchers a useful development environment to use while working on their OpenSAFELY projects. We ship this configuration to researchers within the `.devcontainer` directory of the [OpenSAFELY research template](https://github.com/opensafely/research-template). This configuration makes reference to a [custom research template docker image](https://github.com/opensafely-core/research-template-docker) which we have built for this purpose.

The `.devcontainer` directory is one of the [standard locations](https://code.visualstudio.com/docs/devcontainers/create-dev-container#_create-a-devcontainerjson-file) for the `devcontainer.json` file, which is the primary configuration file for dev containers. The other location option is put this json file in the root of the project directory.

Elements of configuration of the dev container can exist in both the research template docker image, and others in the `.devcontainer` directory (e.g. `devcontainer.json` and supporting scripts/files). Updates to `.devcontainer` in the research template will require a mechanism to push these updates to research repos derived from this template. Updates to the research template docker image will require building and publishing of this image to a container registry. We have implemented a [CI action](https://github.com/opensafely-core/research-template-docker/actions/workflows/main.yml) to build and publish the research template docker image on merge to the `main` branch and scheduled weekly.

One element of the dev container configuration which cannot easily be set in the docker image build is that of setting working directories for R/RStudio to the [workspace folder](https://containers.dev/implementors/json_reference/#variables-in-devcontainerjson) which is (by default) not known until container creation time.


New repositories created from the research template will contain the latest `.devcontainer` directory as of their creation. There is a need to deploy the `.devcontainer` directory to existing research repos, both for initial addition of dev containers/codespaces functionality to the repo, and for future configuration updates. Options for deployment of the template `.devcontainer` directory to existing research repos include:
* manual deployment by researchers
* manual deployment by Team REX
* automated deployment

Options for the degree of ownership of this directory include: 
* Team REX for both the template and in deployed versions in researcher repos
* Team REX for the template and research repo owners for deployed versions in research repos

We wish to minimise the effort of Team REX in supporting codespaces, and so wish to minimise divergence from a standard configuration. However, we acknowledge there may be circumstances in which researchers have a legitimate need for custom configuration. Any deployment of updates to the `.devcontainer` directory to a research repo should ideally be respectul of this.


## Decision

We will move as much of the dev container configuration as possible to the research template docker image in order to minimise changes to the `.devcontainer` directory. This is in order to minimise researcher effort of manual configuration updates to research repositories.

We will keep any dev container configuration in research-template repo within the `.devcontainer` directory where possible. Putting it in this subdirectory helps separate this configuration from researcher code.

This does not preclude further changes to the `.devcontainer` directory where neccesary.

The `.devcontainer` directory within the research-template repo is the responsibility of Team REX.

The `.devcontainer` directory within a research repo is the responsibility of the owners of that repo.

We expect researchers to copy the `.devcontainer` directory to their individual research repos where needed.


## Consequences

We have documented the responsibility of Team REX for the `.devcontainer` folder within its [README](https://github.com/opensafely/research-template/blob/main/.devcontainer/README.md), and make recommendations against researcher modification of its contents unless entirely neccessary.

We have provided [instructions](https://docs.opensafely.org/getting-started/how-to/add-github-codespaces-to-your-project/) for adding the dev container configuration to existing research repos.

Once copied to a research repo, the `.devcontainer` directory is no longer under the _direct_ control of Team REX, but we expect to provide _some_ support for it.

We may investigate automated deployment of updates to the `.devcontainer` directory to research repos in the future, there are still some unknowns around this process and want to learn more.