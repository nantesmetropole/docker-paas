FROM nantesmetropole/debian:jessie

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-php5 \
    && rm -rf /var/lib/apt/lists/* && \
    rm -v /etc/php5/apache2/conf.d/*

USER www-data

EXPOSE 80

WORKDIR /var/www/html

CMD ["apache2", "-DFOREGROUND"]
