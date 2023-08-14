#!/usr/bin/env bash

# Validate the input
if [[ -z "$1" ]]; then
    echo "Usage: $0 [BOX_NAME]"
    echo "Please provide a box name as the first argument."
    exit 1
fi

# The box name is the first argument to the script
BOX_NAME="$1"

# URL of the metadata.json file for the cryptoluks/windows Vagrant box
URL="https://app.vagrantup.com/cryptoluks/boxes/${BOX_NAME}"

# Use curl to download the JSON file and pipe it into jq to extract the version
CURRENT_VERSION=$(curl -s "$URL" | jq -r '.versions[0].version')

# Check if the curl request was successful and box exists
if [[ -z "$CURRENT_VERSION" ]] || [[ "$CURRENT_VERSION" == "null" ]]; then
    echo "Error fetching version information or no box found with the name '${BOX_NAME}' from ${URL}"
    exit 1
fi

# Get the current date in the format YYYY-MM-DD
CURRENT_DATE=$(date +%Y-%m-%d)

# Parse the major version (date) and minor version numbers
VERSION_DATE="${CURRENT_VERSION%%.*}"
MINOR_VERSION="${CURRENT_VERSION##*.}"

# Check if the version's date matches the current date
if [[ "$VERSION_DATE" == "$CURRENT_DATE" ]]; then
  # If the version is from today, increment the minor version
  NEXT_MINOR_VERSION=$((MINOR_VERSION + 1))
else
  # Otherwise, reset the minor version to 0
  NEXT_MINOR_VERSION=0
fi

# Echo the next minor version so it can be used by other scripts
echo "$NEXT_MINOR_VERSION"
