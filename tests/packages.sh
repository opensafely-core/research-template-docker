#!/bin/bash
set -euxo pipefail

# Check that the R packages in the OpenSAFELY R image are available in the dev container.
# The R setup we have leads to two sources of packages.
# As a result, this only compares package names;
# some packages are installed multiple times with different version numbers.
# See https://github.com/opensafely-core/research-template-docker/issues/22

# These packages are known to be extra to the local installation.
r_installed_known_extra_packages=$(cat <<-END
"docopt"
"littler"
"spatial"
END
)

# This function expects a CSV format with header line:
# "Package","Version"
# "SomeRPackage","1.0"
extract_quoted_package_names_from_csv() {
    tail -n +2 | \
    cut -d ',' -f1 | \
    sort -u
}

r_docker_packages=$(curl 'https://raw.githubusercontent.com/opensafely-core/r-docker/main/packages.csv' |
    extract_quoted_package_names_from_csv)
r_installed_packages=$(Rscript -e 'write.csv(installed.packages()[, c("Package", "Version")], row.names = FALSE)' |
    extract_quoted_package_names_from_csv)
r_packages_extra_to_local_install=$(comm -13 <(echo "$r_docker_packages") <(echo "$r_installed_packages"))

[ "$r_packages_extra_to_local_install" == "$r_installed_known_extra_packages" ]

# Check that the Python packages in the OpenSAFELY Python image are available in the dev container.
# This checks package names and versions.
python_image_version='v2'
python_image="ghcr.io/opensafely-core/python:$python_image_version"

docker pull "$python_image"

python_docker_packages=$(docker run "$python_image" python -m pip freeze)
python_installed_packages=$(/opt/venv/bin/python3.10 -m pip freeze)
diff <(echo "$python_docker_packages") <(echo "$python_installed_packages")
