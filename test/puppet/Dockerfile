FROM nantesmetropole/debian:stretch

RUN set -x && \
    apt-get update && \
    apt-get install -y \
        git \
        puppet-lint \
        rgxg \
        ruby-puppetlabs-spec-helper \
        ruby-puppet-syntax \
        ruby-rspec-puppet \
    && rm -rf /var/lib/apt/lists/* && \
        echo Done

USER nobody
