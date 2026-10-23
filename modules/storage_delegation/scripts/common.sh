#!/usr/bin/env bash
# Shared helpers for the watsonx.ai storage delegation scripts.
# Source this file, do not run it directly.

set -o errexit
set -o nounset
set -o pipefail

export PATH=$PATH:${BINARIES_PATH:-"/tmp"}

# Map a region to the IBM watsonx platform UI host, which serves the
# storage delegation API under /api/rest/v1.
# Sets the global variable storage_delegation_api.
set_storage_delegation_api() {
    local region="$1"
    local host
    case "$region" in
        us-south) host="dataplatform.cloud.ibm.com" ;;
        eu-gb) host="eu-gb.dataplatform.cloud.ibm.com" ;;
        eu-de) host="eu-de.dataplatform.cloud.ibm.com" ;;
        jp-tok) host="jp-tok.dataplatform.cloud.ibm.com" ;;
        au-syd) host="au-syd.dai.cloud.ibm.com" ;;
        ca-tor) host="ca-tor.dai.cloud.ibm.com" ;;
        *) echo "Unknown region: $region" >&2 && exit 1 ;;
    esac
    storage_delegation_api="https://${host}/api/rest/v1/storage-delegations"
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

require_jq() {
    if ! command -v jq > /dev/null 2>&1; then
        echo "jq is required but was not found on PATH." >&2
        exit 1
    fi
}

require_jq
