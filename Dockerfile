FROM alex71btc/lnd-dev:0.20.1-beta-dev

ARG ARCH
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    curl \
    jq \
    yq \
    netcat-openbsd \
    openssh-client \
    openssl \
    sshpass \
    xxd \
    ca-certificates \
    make \
    git \
    iproute2 \
    net-tools \
    vim-common \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/lnd

ADD ./configurator/target/${ARCH}-unknown-linux-musl/release/configurator /usr/local/bin/configurator
ADD ./health-check/target/${ARCH}-unknown-linux-musl/release/health-check /usr/local/bin/health-check
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
ADD ./actions/*.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
