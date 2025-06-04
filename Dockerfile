FROM nextcloud:fpm-alpine

RUN groupadd -g 1000 nextcloud && \
    useradd -G 1000 -u 1000 -d /var/www/html/nextcloud nextcloud

RUN chown -R nextcloud:nextcloud /var/www/html/nextcloud

USER nextcloud
WORKDIR /var/www/html/nextcloud

RUN php occ app:install gpxpod && \
    php occ app:install cookbook


