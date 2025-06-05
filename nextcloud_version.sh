#!/bin/sh
# output the latest nextcloud version

curl -s https://apps.nextcloud.com/api/v1/platforms.json | jq -r 'map(select(.isSupported == true) | select(.hasRelease == true)) | max_by(.version | split(".") | join("")) | .version'
