#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Copyright (c) Anil Madhavapeddy
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Maintainer: Anil Madhavapeddy <anil@recoil.org>

OCAML_VERSION=${OCAML_VERSION:-"4.14.0"}
USERNAME=${USERNAME:-"automatic"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# Get central common setting
get_common_setting() {
    if [ "${common_settings_file_loaded}" != "true" ]; then
        curl -sfL "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        common_settings_file_loaded=true
    fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        local multi_line=""
        if [ "$2" = "true" ]; then multi_line="-z"; fi
        local result="$(grep ${multi_line} -oP "$1=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"
        if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
    fi
    echo "$1=${!1}"
}

apt_get_update()
{
    echo "Running apt-get update..."
    apt-get update -y
}

export DEBIAN_FRONTEND=noninteractive

if ! dpkg -s curl ca-certificates gnupg2 lldb build-essential > /dev/null 2>&1; then
    apt_get_update
    apt-get -y install curl ca-certificates gnupg2 lldb build-essential
fi

architecture="$(dpkg --print-architecture)"

# Install OCaml deb
echo "Installing OCaml..."
mkdir -p /tmp/ocaml-dev-tools
cd /tmp/ocaml-dev-tools
curl -OL "https://github.com/avsm/ocaml-devcontainers/releases/download/debs/ocaml-dev-tools_${OCAML_VERSION}_${architecture}.deb"
dpkg -i ocaml-dev-tools_${OCAML_VERSION}_${architecture}.deb
cd /
rm -rf /tmp/ocaml-dev-tools

echo "Done!"
