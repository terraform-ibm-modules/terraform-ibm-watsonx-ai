#!/usr/bin/env bash
# Creates the COS storage delegation, or patches it when it already exists.
# Expected environment: iam_token, region, cos_instance_id, delegation_payload (JSON).

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# shellcheck disable=SC2154
set_storage_delegation_api "$region"
set_token

# shellcheck disable=SC2154
if api_call GET "${storage_delegation_api}/${cos_instance_id}" > /dev/null 2>&1; then
    echo "Storage delegation for COS instance $cos_instance_id already exists, updating it."
    # shellcheck disable=SC2154
    api_call PATCH "${storage_delegation_api}/${cos_instance_id}" "$delegation_payload" > /dev/null
    exit 0
fi

api_call POST "$storage_delegation_api" "$delegation_payload" > /dev/null
echo "Created storage delegation for COS instance $cos_instance_id."
