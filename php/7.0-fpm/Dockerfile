FROM nantesmetropole/debian:stretch

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        php7.0-fpm \
    && rm -rf /var/lib/apt/lists/* && \
    rm -v /etc/php/7.0/fpm/conf.d/*

USER www-data

EXPOSE 9000

WORKDIR /var/www/html

CMD ["/usr/sbin/php-fpm7.0"]
