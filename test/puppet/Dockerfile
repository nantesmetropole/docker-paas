FROM nantesmetropole/debian:stretch

RUN set -x && \
    head -1 /etc/apt/sources.list | sed s/stretch/sid/ > /etc/apt/sources.list.d/sid.list && \
    echo 'APT::Default-Release "stretch";' > /etc/apt/apt.conf.d/default-release && \
    apt-get update && \
    apt-get install -y \
        git \
        octocatalog-diff \
        puppet-lint \
        r10k \
        rgxg \
        ruby-puppet-syntax \
        ruby-puppetlabs-spec-helper \
        ruby-rspec-puppet \
    && rm -rf /var/lib/apt/lists/* && \
    echo Done

USER nobody
