FROM nantesmetropole/debian:stretch

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        libtcnative-1 \
        openjdk-8-jre-headless \
        tomcat8 \
    && rm -rf /var/lib/apt/lists/* && \
    cp -a /etc/tomcat8/server.xml /etc/tomcat8/server.xml.orig && \
    cat /etc/tomcat8/server.xml.orig \
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Connector port="8009"[^>]+>\n?)(\s+-->\n?)/\2/' \
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Listener className="org.apache.catalina.core.AprLifecycleListener"[^>]+>\n?)(\s+-->\n?)/\2/' \
        > /etc/tomcat8/server.xml && \
    (diff -u /etc/tomcat8/server.xml.orig /etc/tomcat8/server.xml ||:)

ENV CATALINA_HOME=/usr/share/tomcat8 \
    CATALINA_BASE=/var/lib/tomcat8

USER tomcat8

EXPOSE 8009 8080

LABEL name="Debian Base Image" \
      vendor="Nantes Métropole"

VOLUME /var/cache/tomcat8 $CATALINA_BASE /var/log/tomcat8

CMD ["/usr/share/tomcat8/bin/catalina.sh", "run"]
