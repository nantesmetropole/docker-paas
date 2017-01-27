FROM nantesmetropole/debian:wheezy

COPY apache2-foreground /usr/local/bin/

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-php5 \
    && rm -rf /var/lib/apt/lists/* && \
    rm -v /etc/php5/conf.d/*

USER www-data

EXPOSE 80

WORKDIR /var/www/html

CMD ["apache2-foreground"]
