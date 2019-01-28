#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

source "${PROJECT_DIR}/bin/TOOL_VERSIONS.sh"
source "${PROJECT_DIR}/SETTINGS.sh"

if [[ -t 0 ]]; then
  INTERACTIVE="-it"
else
  INTERACTIVE=""
fi

docker run ${INTERACTIVE} --rm \
    -e "AWS_PROFILE=${AWS_PROFILE_DEPLOY}" \
    -e TF_LOG \
    -e TF_INPUT \
    -e "TF_VAR_allow_ssh_from_cidr=${ALLOW_SSH_FROM_CIDR}" \
    -e "TF_VAR_cloudwatch_log_group=${CLOUDWATCH_LOG_GROUP}" \
    -e "TF_VAR_ecs_ami_name=${ECS_AMI_NAME}" \
    -e "TF_VAR_kong_image=${KONG_IMAGE}" \
    -e "TF_VAR_region=${AWS_REGION}" \
    -e "TF_VAR_ssh_key_pair_name=${SSH_KEY_PAIR_NAME}" \
    -e "TF_VAR_stack_name=${STACK_NAME}" \
    -v "${HOME}/.aws:/root/.aws:ro" \
    -v "${PROJECT_DIR}:/work" \
    -w /work \
    "hashicorp/terraform:${TERRAFORM_VERSION}" "$@"
