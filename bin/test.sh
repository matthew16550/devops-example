#! /usr/bin/env bash

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${PROJECT_DIR}"

bin/smoketest.sh

bin/inspec.sh exec -t aws:// test/aws
