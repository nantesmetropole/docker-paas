FROM nantesmetropole/debian:stretch

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        docker-registry \
    && rm -rf /var/lib/apt/lists/* && \
        echo Done

USER docker-registry

EXPOSE 5000

VOLUME ["/var/lib/docker-registry"]

ENTRYPOINT ["/usr/bin/docker-registry"]

CMD ["serve", "/etc/docker/registry/config.yml"]
