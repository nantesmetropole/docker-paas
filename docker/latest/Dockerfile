FROM nantesmetropole/debian:stretch

COPY etc/ /etc/

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates && \
    echo "deb https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y \
        docker-ce \
    && rm -rf /var/lib/apt/lists/* && \
        echo Done
