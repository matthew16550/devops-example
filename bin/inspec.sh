#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

source "${PROJECT_DIR}/bin/TOOL_VERSIONS.sh"
source "${PROJECT_DIR}/SETTINGS.sh"

docker run -it --rm \
    -e "AWS_PROFILE=$AWS_PROFILE_TEST" \
    -e AWS_REGION \
    -e KONG_URL="$(bin/terraform.sh output kong_url | tr -d "\r\n")" \
    -e VPC_ID="$(bin/terraform.sh output vpc_id | tr -d "\r\n")" \
    -v "${HOME}/.aws:/root/.aws:ro" \
    -v "${PROJECT_DIR}:/share" \
    "chef/inspec:${INSPEC_VERSION}" "$@"
