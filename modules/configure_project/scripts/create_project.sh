#!/usr/bin/env bash
# Creates the watsonx.ai project if a project with the same name does not exist yet.
# Expected environment: iam_token, region, project_name, project_payload (JSON).

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# shellcheck disable=SC2154
set_dataplatform_api "$region"
set_token

# shellcheck disable=SC2154
existing_id="$(find_project_id "$project_name")"
if [ -n "$existing_id" ]; then
    echo "Project '$project_name' already exists with ID $existing_id, skipping create."
    exit 0
fi

# shellcheck disable=SC2154
response="$(api_call POST "${dataplatform_api}/transactional/v2/projects?verify_unique_name=true" "$project_payload")"
echo "Created project '$project_name': $(echo "$response" | jq -r '.location // .')"
