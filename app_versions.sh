#!/bin/bash
set -x

# gather app latest versions and output it as json
# ./app_versions.sh 31.0.5 calendar gpxpod cookbook

NEXTCLOUD_VERSION=$1
APPS_NAME=${@:2}

curl -s "https://apps.nextcloud.com/api/v1/platform/${NEXTCLOUD_VERSION}/apps.json" -o /tmp/apps-"$NEXTCLOUD_VERSION".json

APPS=$(IFS=, ; echo "\"${APPS_NAME[*]}\"")

jq "map(select(.id | IN($APPS))) | map({(.id): .releases | max_by(.version | split(\".\") | join(\"\")) | { download, version } }) | add" < /tmp/apps-$NEXTCLOUD_VERSION.json
