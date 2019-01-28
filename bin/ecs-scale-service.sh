#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

source "${PROJECT_DIR}/SETTINGS.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <service_name> <desired_count> [--wait]"
  exit 1
fi

SERVICE="$1"
DESIRED_COUNT="$2"
WAIT="$3"

echo "Setting DesiredCount of '${SERVICE}' service to ${DESIRED_COUNT} ..."

"${PROJECT_DIR}/bin/aws.sh" ecs update-service \
    --cluster "${STACK_NAME}" \
    --service "${SERVICE}" \
    --desired-count "${DESIRED_COUNT}" \
    --query 'service.{Desired:desiredCount, Pending:pendingCount, Running:runningCount}'

echo -e "See in ECS Console: https://${AWS_REGION}.console.aws.amazon.com/ecs/home?region=${AWS_REGION}#/clusters/${STACK_NAME}/services/${SERVICE}/tasks\n"

if [[ "$WAIT" == "--wait" ]]; then
    echo "Waiting for service to stabilise ..."

    "${PROJECT_DIR}/bin/aws.sh" ecs wait services-stable \
        --cluster "${STACK_NAME}" \
        --services hello "$SERVICE"
fi
