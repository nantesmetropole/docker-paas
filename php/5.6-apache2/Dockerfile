FROM nantesmetropole/debian:jessie

COPY apache2-foreground /usr/local/bin/

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-php5 \
    && rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf && \
    sed -i 's/^<VirtualHost \*:80>$/<VirtualHost *:8080>/' /etc/apache2/sites-available/*default* && \
    rm -v /etc/php5/apache2/conf.d/*

USER www-data

EXPOSE 8080

WORKDIR /var/www/html

CMD ["apache2-foreground"]
