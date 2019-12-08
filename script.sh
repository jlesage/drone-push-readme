#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

# Set default value of parameters.
PLUGIN_README="${PLUGIN_README:-README.md}"

# Validate parameters.
if [[ -z "$PLUGIN_USERNAME" ]]; then
    printf "Docker Hub username not set.\n"
    exit 1
elif [[ -z "$PLUGIN_PASSWORD" ]]; then
    printf "Docker Hub password not set.\n"
    exit 1
elif [[ -z "$PLUGIN_REPO" ]]; then
    printf "Docker Hub repository not set.\n"
    exit 1
elif [[ ! -r "$PLUGIN_README" ]]; then
    printf "README not found\n."
    exit 1
fi

# Login to Docker Hub.
printf "Logging in to Docker Hub...\n"
declare -r token=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"username": "'"$PLUGIN_USERNAME"'", "password": "'"$PLUGIN_PASSWORD"'"}' \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

# Make sure we got the JWT token.
if [[ "${token}" = "null" ]]; then
    printf "Unable to login to Docker Hub.\n"
    exit 1
fi

# Push the README.
printf "Pushing $PLUGIN_README to $PLUGIN_REPO ...\n"
declare -r code=$(jq -n --arg msg "$(<$PLUGIN_README)" \
    '{"registry":"registry-1.docker.io","full_description": $msg }' | \
        curl -s -o /dev/null  -L -w "%{http_code}" \
            https://hub.docker.com/v2/repositories/"$PLUGIN_REPO"/ \
            -d @- -X PATCH \
            -H "Content-Type: application/json" \
            -H "Authorization: JWT ${token}")

# Validate the result.
if [[ "${code}" = "200" ]]; then
    printf "Successfully pushed README to Docker Hub.\n"
else
    printf "Unable to push README to Docker Hub, response code: %s\n" "${code}"
    exit 1
fi

# vim:ts=4:sw=4:et:sts=4
