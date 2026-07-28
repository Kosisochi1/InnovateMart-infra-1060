#!/usr/bin/env bash
set -e

echo "==============================="
echo "Validate the IaC"
echo "==============================="



ROOT_DIR="../terraform"


cd "${ROOT_DIR}"

terraform validate
