#!/usr/bin/env bash
# Deletes the COS storage delegation.
# Runs from a destroy time provisioner, so it authenticates with an API key from the
# environment (IBMCLOUD_API_KEY, IC_API_KEY or TF_VAR_ibmcloud_api_key).
# Expected environment: region, cos_instance_id.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# shellcheck disable=SC2154
set_storage_delegation_api "$region"
set_token

# shellcheck disable=SC2154
if ! api_call GET "${storage_delegation_api}/${cos_instance_id}" > /dev/null 2>&1; then
    echo "Storage delegation for COS instance $cos_instance_id was not found, nothing to delete."
    exit 0
fi

api_call DELETE "${storage_delegation_api}/${cos_instance_id}" > /dev/null
echo "Deleted storage delegation for COS instance $cos_instance_id."
