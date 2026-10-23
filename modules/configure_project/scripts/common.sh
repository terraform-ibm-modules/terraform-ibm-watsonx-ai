#!/usr/bin/env bash
# Shared helpers for the watsonx.ai project scripts.
# Source this file, do not run it directly.

set -o errexit
set -o nounset
set -o pipefail

export PATH=$PATH:${BINARIES_PATH:-"/tmp"}

# Map a region to the IBM watsonx platform API host.
# Sets the global variable dataplatform_api.
set_dataplatform_api() {
    local region="$1"
    case "$region" in
        us-south) dataplatform_api="https://api.dataplatform.cloud.ibm.com" ;;
        eu-gb) dataplatform_api="https://api.eu-gb.dataplatform.cloud.ibm.com" ;;
        eu-de) dataplatform_api="https://api.eu-de.dataplatform.cloud.ibm.com" ;;
        jp-tok) dataplatform_api="https://api.jp-tok.dataplatform.cloud.ibm.com" ;;
        au-syd) dataplatform_api="https://api.au-syd.dai.cloud.ibm.com" ;;
        ca-tor) dataplatform_api="https://api.ca-tor.dai.cloud.ibm.com" ;;
        *) echo "Unknown region: $region" >&2 && exit 1 ;;
    esac
}

# Resolve an IAM access token.
# Uses the token passed in by Terraform (iam_token, "Bearer <token>") when present.
# Otherwise exchanges an API key from the environment, which is what destroy time
# provisioners rely on because they cannot read provider data sources.
# Sets the global variable token.
set_token() {
    if [ -n "${iam_token:-}" ]; then
        token="$(echo "$iam_token" | awk '{print $2}')"
        return
    fi

    local api_key="${IBMCLOUD_API_KEY:-${IC_API_KEY:-${TF_VAR_ibmcloud_api_key:-}}}"
    if [ -z "$api_key" ]; then
        echo "No IAM token was passed in and none of IBMCLOUD_API_KEY, IC_API_KEY or TF_VAR_ibmcloud_api_key is set." >&2
        exit 1
    fi

    local iam_endpoint="${IBMCLOUD_IAM_API_ENDPOINT:-https://iam.cloud.ibm.com}"
    local response
    response="$(curl --silent --show-error --fail --retry 3 --retry-delay 2 \
        -X POST "${iam_endpoint}/identity/token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --header "Accept: application/json" \
        --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
        --data-urlencode "apikey=${api_key}")"
    token="$(echo "$response" | jq -r '.access_token')"
    if [ -z "$token" ] || [ "$token" == "null" ]; then
        echo "Failed to obtain an IAM token from the API key." >&2
        exit 1
    fi
}

# Perform an HTTP call against the platform API.
# Usage: api_call <METHOD> <URL> [JSON body]
# Prints the response body on stdout and fails on a non 2xx status code.
api_call() {
    local method="$1"
    local url="$2"
    local body="${3:-}"
    local tmp
    tmp="$(mktemp)"

    local status
    if [ -n "$body" ]; then
        status="$(curl --silent --show-error --location --retry 3 --retry-delay 2 \
            --output "$tmp" --write-out "%{http_code}" \
            -X "$method" "$url" \
            --header "Content-Type: application/json" \
            --header "Accept: application/json" \
            --header "Authorization: Bearer $token" \
            --data-raw "$body")"
    else
        status="$(curl --silent --show-error --location --retry 3 --retry-delay 2 \
            --output "$tmp" --write-out "%{http_code}" \
            -X "$method" "$url" \
            --header "Accept: application/json" \
            --header "Authorization: Bearer $token")"
    fi

    cat "$tmp"
    rm -f "$tmp"

    if [ "$status" -lt 200 ] || [ "$status" -ge 300 ]; then
        echo "" >&2
        echo "$method $url returned HTTP $status" >&2
        return 1
    fi
}

# Find a project ID by its name. Prints the ID, or nothing when not found.
# Usage: find_project_id <project name>
find_project_id() {
    local name="$1"
    local encoded
    encoded="$(jq -rn --arg v "$name" '$v | @uri')"
    api_call GET "${dataplatform_api}/v2/projects?name=${encoded}&limit=100" |
        jq -r --arg name "$name" '.resources[]? | select(.entity.name == $name) | .metadata.guid' |
        head -n 1
}

require_jq() {
    if ! command -v jq > /dev/null 2>&1; then
        echo "jq is required but was not found on PATH." >&2
        exit 1
    fi
}

require_jq
