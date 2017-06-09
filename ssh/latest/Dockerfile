FROM nantesmetropole/debian:stretch

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        openssh-client \
    && rm -rf /var/lib/apt/lists/* && \
    adduser --disabled-login --gecos 'SSH relay' --uid 1000 sshrelay

USER sshrelay
