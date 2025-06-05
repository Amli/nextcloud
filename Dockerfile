FROM nextcloud:fpm-alpine

RUN apk add jq bash

RUN addgroup --gid 1000 nextcloud && \
    adduser --ingroup nextcloud --uid 1000 --no-create-home --gecos "" --disabled-password --home /var/www/html/nextcloud nextcloud
RUN mkdir -p /data && chown -R nextcloud:nextcloud /data

RUN mv /usr/src/nextcloud/* /var/www/html/

COPY container/entrypoint.sh container/install_apps.sh app_versions.json apps.txt /
RUN chmod +x /entrypoint.sh /install_apps.sh
RUN /install_apps.sh /var/www/html/custom_apps

USER nextcloud
WORKDIR /var/www/html

ENV NEXTCLOUD_DATA_DIR=/data

###
# latest release
# $(curl -s https://apps.nextcloud.com/api/v1/platforms.json | jq -r 'map(select(.isSupported == true) | select(.hasRelease == true)) | max_by(.version | split(".") | join("")) | .version')

###
# manual app install
# APP_DL_URL=$(curl -s 'https://apps.nextcloud.com/api/v1/platform/31.0.5/apps.json' | jq 'map(select(.id == "calendar")) | .[0] | .releases | max_by(.version | split(".") | join("")) | .download')
# curl -L '$APP_DL_URL' -o - | tar xzv --directory=test/
