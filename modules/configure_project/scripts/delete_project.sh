#!/usr/bin/env bash
# Deletes the watsonx.ai project that matches the given name.
# Runs from a destroy time provisioner, so it authenticates with an API key from the
# environment (IBMCLOUD_API_KEY, IC_API_KEY or TF_VAR_ibmcloud_api_key).
# Expected environment: region, project_name.

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# shellcheck disable=SC2154
set_dataplatform_api "$region"
set_token

# shellcheck disable=SC2154
project_id="$(find_project_id "$project_name")"
if [ -z "$project_id" ]; then
    echo "Project '$project_name' was not found, nothing to delete."
    exit 0
fi

api_call DELETE "${dataplatform_api}/transactional/v2/projects/${project_id}" > /dev/null
echo "Deleted project '$project_name' ($project_id)."
