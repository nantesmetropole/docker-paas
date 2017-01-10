FROM nantesmetropole/debian:jessie

MAINTAINER Mathieu Parent <math.parent@gmail.com>

RUN apt-get update && \
    apt-get install -y \
        libtcnative-1 \
        openjdk-7-jre-headless \
        tomcat7 \
    && rm -rf /var/lib/apt/lists/* && \
    cp -a /etc/tomcat7/server.xml /etc/tomcat7/server.xml.orig && \
    cat /etc/tomcat7/server.xml.orig \
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Connector port="8009"[^>]+>\n?)(\s+-->\n?)/\2/' \
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Listener className="org.apache.catalina.core.AprLifecycleListener"[^>]+>\n?)(\s+-->\n?)/\2/' \
        > /etc/tomcat7/server.xml && \
    (diff -u /etc/tomcat7/server.xml.orig /etc/tomcat7/server.xml ||:)

ENV CATALINA_HOME=/usr/share/tomcat7 \
    CATALINA_BASE=/var/lib/tomcat7

USER tomcat7

EXPOSE 8009 8080

LABEL name="Debian Base Image" \
      vendor="Nantes Métropole"

VOLUME /var/cache/tomcat7 $CATALINA_BASE /var/log/tomcat7

CMD ["/usr/share/tomcat7/bin/catalina.sh", "run"]

ONBUILD COPY *.war $CATALINA_BASE/webapps/
ONBUILD COPY *.xml /etc/tomcat7/Catalina/localhost/
