#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${PROJECT_DIR}"

source SETTINGS.sh

if [[ ! -e .terraform ]]; then
  echo -e "\n--- terraform init ---\n"
  bin/terraform.sh init terraform
fi

# Create log group if it doesnt exist
if [[ "$(bin/aws.sh logs describe-log-groups --log-group-name-prefix "${CLOUDWATCH_LOG_GROUP}" --query 'logGroups[] | length(@)' | tr -d "\r\n")" != "1" ]]; then
  echo -e "Creating '${CLOUDWATCH_LOG_GROUP}' Log Group ..."
  bin/aws.sh logs create-log-group --log-group-name "${CLOUDWATCH_LOG_GROUP}"
fi

echo -e "\n--- terraform apply ---\n"

bin/terraform-apply.sh

echo -e "\n--- Initializing Kong Database ---\n"

bin/ecs-run-task.sh "${STACK_NAME}-kong-migration-bootstrap" --wait

echo -e "\n--- Configuring Kong ---\n"

bin/ecs-run-task.sh "${STACK_NAME}-kong-configure" --wait

echo -e "\n--- Starting Services ---\n"

bin/ecs-scale-service.sh kong-proxy 1

bin/ecs-scale-service.sh hello 1

echo -e "\n--- Finished (but services might still be starting) ---\n"

bin/terraform.sh output
