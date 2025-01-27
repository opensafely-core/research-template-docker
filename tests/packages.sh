#!/bin/bash
set -euxo pipefail

# This test requires:
# * Docker
# * the availability of the research-template Docker image
research_template_image="research-template"
docker image inspect "$research_template_image" > /dev/null

# These checks assume that the packages do not change
# between building the Docker image in this repository,
# and checking the packages against the OpenSAFELY R and Python images.

# Check that the R packages in the OpenSAFELY R image are available in the dev container.
# The R setup we have leads to two sources of packages.
# As a result, this only compares package names;
# some packages are installed multiple times with different version numbers.
# See https://github.com/opensafely-core/research-template-docker/issues/22

# These packages are known to be extra to the local installation. Must be sorted.
r_installed_known_extra_packages=$(cat <<END
"docopt"
"littler"
"spatial"
END
)

extract_quoted_package_names_from_json() {
    jq '.Packages | keys[]' | sort -u
}

r_docker_packages=$(curl -s 'https://raw.githubusercontent.com/opensafely-core/r-docker/main/v1/renv.lock' | extract_quoted_package_names_from_json)

r_script="
t <- tempfile()
n=file(nullfile(), open='wt')
sink(n) # stdout
sink(n, type='message')  # stderr
renv::snapshot(lockfile=t, type='all')
sink()
sink(type = 'message')
cat(readLines(t))
"
r_installed_packages=$(docker run -i "$research_template_image" Rscript -e "$r_script" | extract_quoted_package_names_from_json)

r_packages_extra_to_local_install=$(comm -13 <(echo "$r_docker_packages") <(echo "$r_installed_packages") | awk NF | sort -u)

if [ "$r_packages_extra_to_local_install" != "$r_installed_known_extra_packages" ]; then
    set +x
    echo "There are unexpected extra R packages installed:"
    comm -13 <(echo "$r_installed_known_extra_packages") <(echo "$r_packages_extra_to_local_install") 
    exit 1;
fi

# Check that the Python packages in the OpenSAFELY Python image are available in the dev container.
# This checks package names and versions.
python_image_version='v2'
python_image="ghcr.io/opensafely-core/python:$python_image_version"

docker pull "$python_image"

python_docker_packages=$(docker run "$python_image" python -m pip freeze)
python_installed_packages=$(docker run "$research_template_image" /opt/venv/bin/python3.10 -m pip freeze)
diff <(echo "$python_docker_packages") <(echo "$python_installed_packages")
