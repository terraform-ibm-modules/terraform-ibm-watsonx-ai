#!/usr/bin/env bash
# Patches the watsonx.ai project with the current name, description and compute settings.
# Expected environment: iam_token, region, project_name, project_patch (JSON).

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# shellcheck disable=SC2154
set_dataplatform_api "$region"
set_token

# shellcheck disable=SC2154
project_id="$(find_project_id "$project_name")"
if [ -z "$project_id" ]; then
    echo "Project '$project_name' was not found, nothing to update." >&2
    exit 1
fi

# shellcheck disable=SC2154
api_call PATCH "${dataplatform_api}/v2/projects/${project_id}" "$project_patch" > /dev/null
echo "Updated project '$project_name' ($project_id)."
