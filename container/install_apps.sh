#!/bin/bash
set -x

DESTINATION=$1

while read app
do
    echo "downloading and extracting $app"
    url=$(jq -r ".[\"$app\"].download" < /app_versions.json)
    curl -s -L "$url" -o - | tar xzv --directory="$DESTINATION"
done < /apps.txt