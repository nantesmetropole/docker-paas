FROM nantesmetropole/debian:stretch

COPY etc/ /etc/

RUN \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates && \
    echo "deb https://apt.dockerproject.org/repo debian-stretch main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y \
        docker-engine \
    && rm -rf /var/lib/apt/lists/* && \
        echo Done
