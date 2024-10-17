FROM ubuntu:22.04

LABEL maintainer="Josh.5 <jsunnex@gmail.com>"

RUN \
    echo "**** Install dependencies ****" \
        && apt-get update \
        && apt-get install --no-install-recommends -y \
            apt-transport-https \
            apt-utils \
            btrfs-progs \
            ca-certificates \
            curl \
            e2fsprogs \
            git \
            gnupg \
            iproute2 \
            iptables \
            libssl-dev \
            openssh-client \
            openssl \
            pigz \
            software-properties-common \
            uidmap \
            wget \
            xfsprogs \
            xz-utils \
            zfsutils-linux \
    && \
    echo "**** Section cleanup ****" \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/*

# pre-add a "docker" group for socket usage
RUN addgroup --system --gid 2375 docker

ARG DOCKER_VERSION=27.3.1
ENV DOCKER_VERSION=$DOCKER_VERSION
RUN set -eux; \
    \
    imageArch="$(uname -m)"; \
    case "$imageArch" in \
        'x86_64') \
            url="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION:?}.tgz"; \
            ;; \
        'armhf') \
            url="https://download.docker.com/linux/static/stable/armel/docker-${DOCKER_VERSION:?}.tgz"; \
            ;; \
        'armv7') \
            url="https://download.docker.com/linux/static/stable/armhf/docker-${DOCKER_VERSION:?}.tgz"; \
            ;; \
        'aarch64') \
            url="https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VERSION:?}.tgz"; \
            ;; \
        *) echo >&2 "error: unsupported 'docker.tgz' architecture ($imageArch)"; exit 1 ;; \
    esac; \
    \
    wget -O 'docker.tgz' "$url"; \
    \
    tar --extract \
        --file docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/ \
        --no-same-owner \
    ; \
    rm docker.tgz; \
    \
    docker --version; \
    dockerd --version; \
    containerd --version; \
    ctr --version; \
    runc --version

ARG DOCKER_BUILDX_VERSION=0.16.2
ENV DOCKER_BUILDX_VERSION=$DOCKER_BUILDX_VERSION
RUN set -eux; \
    \
    imageArch="$(uname -m)"; \
    case "$imageArch" in \
        'x86_64') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-amd64"; \
            sha256='43e4c928a0be38ab34e206c82957edfdd54f3e7124f1dadd7779591c3acf77ea'; \
            ;; \
        'armhf') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-arm-v6"; \
            sha256='77678205fbaaead25167cd93b022996d0bafff67deb5ca82b92b25cccb06ad07'; \
            ;; \
        'armv7') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-arm-v7"; \
            sha256='b4f029ed0d4d30c49857bc31f8bec5484b3f6b8104d8d49a187fb6b69fab3d82'; \
            ;; \
        'aarch64') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-arm64"; \
            sha256='775f1ab64aa0e5d901dcc6ecf6843ec3261f27476873760711aa362b403f61f3'; \
            ;; \
        'ppc64le') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-ppc64le"; \
            sha256='956b020318ad0ba94f817116792d9da8695ebab38254c9f821a85a3369175f7e'; \
            ;; \
        'riscv64') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-riscv64"; \
            sha256='e90589ff33ad409a40a5e53cde5af4a0f230f0d8f5b6d9af522120a6900222ea'; \
            ;; \
        's390x') \
            url="https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION:?}/buildx-v${DOCKER_BUILDX_VERSION:?}.linux-s390x"; \
            sha256='f2dbf2dc967415e1e1f4398d040d6b5b81e4e27f37df22bd148ea4b18c8ea6eb'; \
            ;; \
        *) echo >&2 "warning: unsupported 'docker-buildx' architecture ($imageArch); skipping"; exit 0 ;; \
    esac; \
    \
    wget -O 'docker-buildx' "$url"; \
    echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
    \
    plugin='/usr/local/libexec/docker/cli-plugins/docker-buildx'; \
    mkdir -p "$(dirname "$plugin")"; \
    mv -vT 'docker-buildx' "$plugin"; \
    chmod +x "$plugin"; \
    \
    docker buildx version

ARG DOCKER_COMPOSE_VERSION=2.29.1
ENV DOCKER_COMPOSE_VERSION=$DOCKER_COMPOSE_VERSION
RUN set -eux; \
    \
    imageArch="$(uname -m)"; \
    case "$imageArch" in \
        'x86_64') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-x86_64"; \
            sha256='5ea89dd65d33912a83737d8a4bf070d5de534a32b8493a21fbefc924484786a9'; \
            ;; \
        'armhf') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-armv6"; \
            sha256='5fdd0653bb04798f1448bd5bdbecea02bcf39247fcc9b8aab10c05c8e680ede0'; \
            ;; \
        'armv7') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-armv7"; \
            sha256='0d675f39b3089050d0630a7151580a58abc6c189e64209c6403598b6e9fc0b21'; \
            ;; \
        'aarch64') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-aarch64"; \
            sha256='7f0023ba726b90347e4ebc1d94ec5970390b8bddb86402c0429f163dca70d745'; \
            ;; \
        'ppc64le') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-ppc64le"; \
            sha256='9d69aae252fa7fd3a234647951b2af496ee927134d5456d4b8bac31d4d260f5d'; \
            ;; \
        'riscv64') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-riscv64"; \
            sha256='91b6b2f56e8cba3965a5409fa5125d3f01408c9b2d0bf5b9c119f353601d1e51'; \
            ;; \
        's390x') \
            url="https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION:?}/docker-compose-linux-s390x"; \
            sha256='1ea22d04bab9452de3169e22b60d77a232acdf829ac4858dc780085dd7fd4c48'; \
            ;; \
        *) echo >&2 "warning: unsupported 'docker-compose' architecture ($imageArch); skipping"; exit 0 ;; \
    esac; \
    \
    wget -O 'docker-compose' "$url"; \
    echo "$sha256 *"'docker-compose' | sha256sum -c -; \
    \
    plugin='/usr/local/libexec/docker/cli-plugins/docker-compose'; \
    mkdir -p "$(dirname "$plugin")"; \
    mv -vT 'docker-compose' "$plugin"; \
    chmod +x "$plugin"; \
    \
    ln -sv "$plugin" /usr/local/bin/; \
    docker-compose --version; \
    docker compose version

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -eux; \
    addgroup --system dockremap; \
    adduser --system --no-create-home --group dockremap; \
    echo 'dockremap:165536:65536' >> /etc/subuid; \
    echo 'dockremap:165536:65536' >> /etc/subgid

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 65cfcc28ab37cb75e1560e4b4738719c07c6618e

RUN set -eux; \
    wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
    chmod +x /usr/local/bin/dind

# NVIDIA Container Toolkit and Docker
RUN \
    echo "**** Add nvidia runtime apt repo ****" \
        && mkdir -pm755 /etc/apt/keyrings && curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && chmod a+r /etc/apt/keyrings/docker.gpg \
        && mkdir -pm755 /etc/apt/sources.list.d && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"') stable" > /etc/apt/sources.list.d/docker.list \
        && mkdir -pm755 /usr/share/keyrings && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -fsSL "https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list" | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null \
    && \
    echo "**** Install nvidia runtime apt repo ****" \
        && apt-get update \
        && apt-get install --no-install-recommends -y \
            nvidia-container-toolkit \
    && \
    echo "**** Section cleanup ****" \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
                /var/lib/apt/lists/*

COPY modprobe.sh /usr/local/bin/modprobe
COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
