#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

source "${PROJECT_DIR}/bin/TOOL_VERSIONS.sh"
source "${PROJECT_DIR}/SETTINGS.sh"

# There isn't an official aws cli image yet (https://github.com/aws/aws-cli/issues/3553)
# so using one from Mesosphere who should be fairly trustworthy

docker run -it --rm \
    -e "AWS_PROFILE=${AWS_PROFILE_DEPLOY}" \
    -e "AWS_REGION" \
    -v "${HOME}/.aws:/root/.aws:ro" \
    -v "${PROJECT_DIR}:/project" \
    "mesosphere/aws-cli:${AWSCLI_VERSION}" "$@"
