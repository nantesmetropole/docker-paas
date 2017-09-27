FROM nantesmetropole/debian:stretch

COPY etc/ /etc/
COPY dind/* /usr/local/bin/

RUN set -x && \
    adduser --system --group dockremap && \
    echo 'dockremap:165536:65536' >> /etc/subuid && \
    echo 'dockremap:165536:65536' >> /etc/subgid && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates && \
    echo "deb https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y \
        btrfs-progs \
        docker-ce \
        e2fsprogs \
        xfsprogs \
    && rm -rf /var/lib/apt/lists/* && \
    echo Done


VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
