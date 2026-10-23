#!/usr/bin/env bash
# Patches the COS storage delegation with the current KMS key and scope.
# Expected environment: iam_token, region, cos_instance_id, delegation_payload (JSON).

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# shellcheck disable=SC2154
set_storage_delegation_api "$region"
set_token

# shellcheck disable=SC2154
api_call PATCH "${storage_delegation_api}/${cos_instance_id}" "$delegation_payload" > /dev/null
echo "Updated storage delegation for COS instance $cos_instance_id."
