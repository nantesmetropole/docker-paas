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

. "$PWD/scripts/java.sh"

case $TOMCAT_VERSION in
    6)
        tomcat_package="tomcat$TOMCAT_VERSION"
        tomcat_dists="wheezy"
        ;;
    7)
        tomcat_package="tomcat$TOMCAT_VERSION"
        tomcat_dists="jessie wheezy"
        ;;
    8)
        tomcat_package="tomcat$TOMCAT_VERSION"
        tomcat_dists="jessie"
        ;;
    8.5)
        tomcat_package="tomcat8"
        tomcat_dists="stretch"
        ;;
    *)
        echo "ERROR: Mandatory variable is not correct: TOMCAT_VERSION=$TOMCAT_VERSION"
        exit 1
        ;;
esac
tomcat_short="tomcat$TOMCAT_VERSION"
dockerfile_packages="$dockerfile_packages libtcnative-1 $tomcat_package"

dockerfile_path=tomcat/$tomcat_short-$java_short$onbuild_short/Dockerfile
dockerfile_from=nantesmetropole/debian:$DIST

dockerfile_generate_run_cont() {
    cat <<EOF >> "$dockerfile_path"
    && \\
    cp -a /etc/$tomcat_package/server.xml /etc/$tomcat_package/server.xml.orig && \\
    cat /etc/$tomcat_package/server.xml.orig \\
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Connector port="8009"[^>]+>\n?)(\s+-->\n?)/\2/' \\
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Listener className="org.apache.catalina.core.AprLifecycleListener"[^>]+>\n?)(\s+-->\n?)/\2/' \\
        > /etc/$tomcat_package/server.xml && \\
    diff -u /etc/$tomcat_package/server.xml.orig /etc/$tomcat_package/server.xml ||:

ENV CATALINA_HOME=/usr/share/$tomcat_package \\
    CATALINA_BASE=/var/lib/$tomcat_package

USER $tomcat_package

EXPOSE 8009 8080

LABEL name="Debian Base Image" \\
      vendor="Nantes Métropole"

VOLUME \$CATALINA_BASE

CMD ["/usr/share/$tomcat_package/bin/catalina.sh", "run"]
EOF
}

dockerfile_generate_onbuild() {
    cat <<EOF >> "$dockerfile_path"

ONBUILD COPY *.war \$CATALINA_BASE/webapps/
ONBUILD COPY *.xml /etc/$tomcat_package/Catalina/localhost/
EOF
}
