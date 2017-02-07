FROM nantesmetropole/debian:jessie

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        php5-fpm \
    && rm -rf /var/lib/apt/lists/* && \
    sed -i -e 's/^;daemonize = yes/daemonize = no/' \
           -e 's@^error_log =.*@error_log = /proc/self/fd/2@' \
        /etc/php5/fpm/php-fpm.conf && \
    sed -i -e 's/^user =/;user =/' \
           -e 's/^group =/;group =/' \
           -e 's/^listen = .*/listen = 0.0.0.0:9000/' \
           -e 's/^clear_env = .*/clear_env = no/' \
        /etc/php5/fpm/pool.d/www.conf && \
    rm -v /etc/php5/fpm/conf.d/*

USER www-data

EXPOSE 9000

WORKDIR /var/www/html

CMD ["/usr/sbin/php5-fpm"]
