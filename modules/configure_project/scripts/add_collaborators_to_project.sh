#!/usr/bin/env bash

set -e

# shellcheck disable=SC2154
token="$(echo "$iam_token" | awk '{print $2}')"

# shellcheck disable=SC2154
if [ "$region" == "us-south" ]; then
    dataplatform_api="https://api.dataplatform.cloud.ibm.com"
elif [ "$region" == "eu-gb" ]; then
    dataplatform_api="https://api.eu-gb.dataplatform.cloud.ibm.com"
elif [ "$region" == "eu-de" ]; then
    dataplatform_api="https://api.eu-de.dataplatform.cloud.ibm.com"
elif [ "$region" == "jp-tok" ]; then
    dataplatform_api="https://api.jp-tok.dataplatform.cloud.ibm.com"
elif [ "$region" == "au-syd" ]; then
    dataplatform_api="https://api.au-syd.dai.cloud.ibm.com"
elif [ "$region" == "ca-tor" ]; then
    dataplatform_api="https://api.ca-tor.dai.cloud.ibm.com"
else
    echo "Unknown region" && exit 1
fi

# add the user to watson.ai project as an admin
# shellcheck disable=SC2154
curl -s -X POST --location "$dataplatform_api/v2/projects/$project_id/members" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $token" \
    --data-raw "{
            \"members\": [
                {
                    \"user_name\": \"$user_name\",
                    \"id\": \"$iam_id\",
                    \"role\": \"$role\",
                    \"state\": \"$state\",
                    \"type\": \"$type\"
                }
            ]
        }"

# update the role
curl -s -X PATCH --location "$dataplatform_api/v2/projects/$project_id/members" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $token" \
    --data-raw "{
            \"members\": [
                {
                    \"user_name\": \"$user_name\",
                    \"id\": \"$iam_id\",
                    \"role\": \"$role\"
                }
            ]
        }"


# remove the members that are in the project but no longer in the configured list.
# the identity running Terraform is never removed.
if ! command -v jq > /dev/null 2>&1; then
    echo "jq is required to remove members from the project but was not found" >&2
    exit 1
fi

caller_iam_id="$(jq -R 'split(".") | .[1] | gsub("-"; "+") | gsub("_"; "/") | @base64d | fromjson | .iam_id // .sub // empty' -r <<< "$token" 2>/dev/null || echo "")"

if [ -n "$caller_iam_id" ]; then
    current_members="$(curl -s -X GET --location "$dataplatform_api/v2/projects/$project_id/members" \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $token" | jq -r --arg caller "$caller_iam_id" '.members[]? | select(.id != $caller and (.user_name // .id) != $caller) | .user_name // .id')"

    # shellcheck disable=SC2154
    while IFS= read -r member; do
        [ -z "$member" ] && continue
        if ! echo "$configured_members" | tr ',' '\n' | grep -qixF "$member"; then
            echo "Removing $member from project $project_id"
            encoded_member="$(jq -rn --arg m "$member" '$m | @uri')"
            curl -s -X DELETE --location "$dataplatform_api/v2/projects/$project_id/members/$encoded_member" \
                --header "Content-Type: application/json" \
                --header "Authorization: Bearer $token"
        fi
    done <<< "$current_members"
else
    echo "Warning: Could not determine caller identity from IAM token; skipping removal of stale project members" >&2
fi
