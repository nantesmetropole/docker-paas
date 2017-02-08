FROM nantesmetropole/debian:wheezy

COPY apache2-foreground /usr/local/bin/

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-php5 \
    && rm -rf /var/lib/apt/lists/* && \
    sed -i 's@DocumentRoot /var/www$@DocumentRoot /var/www/html@' \
        /etc/apache2/sites-available/* && \
    sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf && \
    sed -i 's/^<VirtualHost \*:80>$/<VirtualHost *:8080>/' /etc/apache2/sites-available/*default* && \
    chgrp www-data /var/log/apache2 && \
    chown www-data /var/run/apache2 && \
    ln -sfT /dev/stderr "/var/log/apache2/error.log"  && \
    ln -sfT /dev/stdout "/var/log/apache2/access.log"  && \
    ln -sfT /dev/stdout "/var/log/apache2/other_vhosts_access.log"  && \
    rm -v /etc/php5/conf.d/*

USER www-data

EXPOSE 8080

WORKDIR /var/www/html

CMD ["apache2-foreground"]
