#!/bin/sh
## Copyright 2017 Mathieu Parent <math.parent@gmail.com>
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

set -e

. "$PWD/src/families/common.sh"

case $PHP_VERSION in
    5.4)
        php_dists="wheezy"
        php_package="php5"
        fpm_bin="/usr/sbin/php5-fpm"
        conf_dir="/etc/php5/conf.d"
        fpm_conf_dir="/etc/php5/fpm"
        ;;
    5.6)
        php_dists="jessie"
        php_package="php5"
        fpm_bin="/usr/sbin/php5-fpm"
        conf_dir="/etc/php5/$PHP_SAPI/conf.d"
        fpm_conf_dir="/etc/php5/fpm"
        ;;
    7.0)
        php_dists="stretch"
        php_package="php$PHP_VERSION"
        fpm_bin="/usr/sbin/php-fpm$PHP_VERSION"
        conf_dir="/etc/php/$PHP_VERSION/$PHP_SAPI/conf.d"
        fpm_conf_dir="/etc/php/$PHP_VERSION/fpm"
        ;;
    *)
        echo "ERROR: Mandatory variable is not correct: PHP_VERSION=$PHP_VERSION"
        exit 1
        ;;
esac

case $PHP_SAPI in
    apache2)
        php_package="apache2 libapache2-mod-$php_package"
        php_port=8080
        php_cmd="[\"apache2-foreground\"]"
        ;;
    fpm)
        php_package="$php_package-$PHP_SAPI"
        php_port=9000
        php_cmd="[\"$fpm_bin\"]"
        ;;
    *)
        echo "ERROR: Mandatory variable is not correct: PHP_SAPI=$PHP_SAPI"
        exit 1
        ;;
esac

dockerfile_packages="$dockerfile_packages $php_package"
php_short="$PHP_VERSION-$PHP_SAPI"

dockerfile_path=php/$php_short$onbuild_short/Dockerfile
if [ -n "$CI_REGISTRY_IMAGE" ]; then
    docker_tag="$(echo $CI_REGISTRY_IMAGE | sed s/paas/php/):$php_short$onbuild_short"
else
    docker_tag=nantesmetropole/php:$php_short$onbuild_short
fi

dockerfile_generate_before_run() {
    if [ "$PHP_SAPI" = "apache2" ]; then
        cp -a templates/php/apache2-foreground "$(dirname "$dockerfile_path")/"
        cat <<EOF >> "$dockerfile_path"
COPY apache2-foreground /usr/local/bin/

EOF
    fi
}

dockerfile_generate_run_cont() {
    if [ "$PHP_SAPI" = "apache2" ]; then
        if [ "$DIST" = "wheezy" ]; then
            cat <<EOF >> "$dockerfile_path"
    sed -i 's@DocumentRoot /var/www\$@DocumentRoot /var/www/html@' \\
        /etc/apache2/sites-available/* && \\
EOF
        fi
        cat <<EOF >> "$dockerfile_path"
    sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf && \\
    sed -i 's/^<VirtualHost \*:80>$/<VirtualHost *:8080>/' /etc/apache2/sites-available/*default* && \\
    chgrp www-data /var/log/apache2 && \\
    chown www-data /var/run/apache2 && \\
    ln -sfT /dev/stderr "/var/log/apache2/error.log"  && \\
    ln -sfT /dev/stdout "/var/log/apache2/access.log"  && \\
    ln -sfT /dev/stdout "/var/log/apache2/other_vhosts_access.log"  && \\
EOF
    elif [ "$PHP_SAPI" = "fpm" ]; then
        cat <<EOF >> "$dockerfile_path"
    sed -i -e 's/^;daemonize = yes/daemonize = no/' \\
           -e 's@^error_log =.*@error_log = /proc/self/fd/2@' \\
        $fpm_conf_dir/php-fpm.conf && \\
    sed -i -e 's/^user =/;user =/' \\
           -e 's/^group =/;group =/' \\
           -e 's/^listen = .*/listen = 0.0.0.0:9000/' \\
           -e 's/^clear_env = .*/clear_env = no/' \\
        $fpm_conf_dir/pool.d/www.conf && \\
EOF
    fi
    cat <<EOF >> "$dockerfile_path"
    rm -v $conf_dir/*

USER www-data

EXPOSE $php_port

WORKDIR /var/www/html

CMD $php_cmd
EOF
}
