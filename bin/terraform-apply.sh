#! /usr/bin/env bash

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${PROJECT_DIR}"

source SETTINGS.sh

bin/terraform.sh apply terraform
