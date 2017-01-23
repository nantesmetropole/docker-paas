FROM nantesmetropole/debian:stretch

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-php7.0 \
    && rm -rf /var/lib/apt/lists/* && \
    rm -v /etc/php/7.0/apache2/conf.d/*

USER www-data

EXPOSE 80

WORKDIR /var/www/html

CMD ["apache2", "-DFOREGROUND"]
