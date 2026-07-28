#!/usr/bin/env bash
set -e 
echo "============================================"
echo "Plan the Infrastructure to be provissioned"
echo "============================================"


ROOT_DIR="../terraform"


cd "${ROOT_DIR}"


terraform plan