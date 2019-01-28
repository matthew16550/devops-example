#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

source "${PROJECT_DIR}/SETTINGS.sh"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <task> [--wait]"
  exit 1
fi

task="$1"

echo -e "\nRunning task ${task} ..."

task_arn=$("${PROJECT_DIR}/bin/aws.sh" ecs run-task \
    --cluster "${STACK_NAME}" \
    --launch-type EC2 \
    --task-definition "${task}" \
    --query 'tasks[0].taskArn' \
    --output text | tr -d "\r\n")

echo "See log in CloudWatch: https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#logStream:group=${CLOUDWATCH_LOG_GROUP}"

if [[ "$2" == "--wait" ]]; then
    echo "Waiting for task ${task_arn} to finish ..."

    "${PROJECT_DIR}/bin/aws.sh" ecs wait tasks-stopped \
        --cluster "${STACK_NAME}" \
        --tasks "${task_arn}"
fi
