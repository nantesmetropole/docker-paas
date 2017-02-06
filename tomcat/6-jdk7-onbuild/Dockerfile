FROM nantesmetropole/debian:wheezy

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        libtcnative-1 \
        openjdk-7-jre-headless \
        tomcat6 \
    && rm -rf /var/lib/apt/lists/* && \
    cp -a /var/lib/tomcat6/webapps/ROOT/META-INF/context.xml /etc/tomcat6/Catalina/localhost/ROOT.xml && \
    cp -a /etc/tomcat6/server.xml /etc/tomcat6/server.xml.orig && \
    cat /etc/tomcat6/server.xml.orig \
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Connector port="8009"[^>]+>\n?)(\s+-->\n?)/\2/' \
        | perl -0777 -pe 's/([ \t]*<!--\n?)(\s+<Listener className="org.apache.catalina.core.AprLifecycleListener"[^>]+>\n?)(\s+-->\n?)/\2/' \
        > /etc/tomcat6/server.xml && \
    (diff -u /etc/tomcat6/server.xml.orig /etc/tomcat6/server.xml ||:)

ENV CATALINA_HOME=/usr/share/tomcat6 \
    CATALINA_BASE=/var/lib/tomcat6

USER tomcat6

EXPOSE 8009 8080

LABEL name="Debian Base Image" \
      vendor="Nantes Métropole"

VOLUME /var/cache/tomcat6 $CATALINA_BASE /var/log/tomcat6

CMD ["/usr/share/tomcat6/bin/catalina.sh", "run"]

ONBUILD COPY *.war $CATALINA_BASE/webapps/
ONBUILD COPY *.xml /etc/tomcat6/Catalina/localhost/
