FROM nantesmetropole/debian:jessie

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        php5-fpm \
    && rm -rf /var/lib/apt/lists/* && \
    rm -v /etc/php5/fpm/conf.d/*

USER www-data

EXPOSE 9000

WORKDIR /var/www/html

CMD ["php5-fpm"]