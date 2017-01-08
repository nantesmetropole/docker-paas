FROM nantesmetropole/debian:jessie

MAINTAINER Mathieu Parent <math.parent@gmail.com>

RUN apt-get update && \
    apt-get install -y \
        openjdk-7-jre-headless \
        tomcat7

ENV CATALINA_HOME=/usr/share/tomcat7 \
    CATALINA_BASE=/var/lib/tomcat7

USER tomcat7

EXPOSE 8080

LABEL name="Debian Base Image" \
      vendor="Nantes Métropole"

VOLUME $CATALINA_BASE

CMD ["$CATALINA_HOME/bin/catalina.sh", "run"]

ONBUILD COPY *.war $CATALINA_BASE/webapps/
ONBUILD COPY *.xml /etc/tomcat7/Catalina/localhost/
