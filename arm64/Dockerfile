# Copyright (c) 2017-2018, Jan Cajthaml <jan.cajthaml@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM arm64/debian:stretch-slim

ENV LANG=C.UTF-8
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=no

RUN \
  apt-get update -y && \
  \
  apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates>=20161130 \
    curl \
    gnupg \
    at \
    git \
    tar \
    gcc \
    lsof \
    make \
    udev \
    dbus \
    cron \
    bison \
    bzip2 \
    autoconf \
    tk-dev \
    uuid-dev \
    dpkg-dev \
    libicu57 \
    libuv1 \
    initscripts \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm3 \
    libglib2.0-dev \
    libreadline-dev \
    libssl-dev \
    libsystemd0 \
    libudev1 \
    logrotate \
    lsb-release \
    netcat-openbsd \
    procps \
    rsyslog \
    ssmtp \
    systemd \
    sysvinit-utils \
    util-linux \
    xz-utils \
    zlib1g-dev \
    apt-transport-https \
    libzmq5>=4.2.1~ \
    libzmq3-dev>=4.2.1~ \
    init-system-helpers>=1.18~

RUN \
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb [ arch=arm64 ] https://deb.nodesource.com/node_10.x xenial main' > /etc/apt/sources.list.d/nodesource.list && \
    echo 'deb-src https://deb.nodesource.com/node_10.x xenial main' >> /etc/apt/sources.list.d/nodesource.list && \
  \
  curl -s https://www.mongodb.org/static/pgp/server-4.0.asc | apt-key add - && \
    echo 'deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse' > /etc/apt/sources.list.d/mongodb-org-4.0.list && \
  :

RUN curl -s "https://mirrors.mediatemple.net/debian-archive/debian/pool/main/o/openssl/libssl1.0.0_1.0.2l-1~bpo8+1_arm64.deb" -O && \
    dpkg -i libssl1.0.0_1.0.2l-1~bpo8+1_arm64.deb && \
    rm libssl1.0.0_1.0.2l-1~bpo8+1_arm64.deb

RUN \
  apt-get update -y && \
  \
  apt-get install -y \
    python3 \
    python3-pip \
    nodejs \
    mongodb-org \
  && :

RUN \
    pip3 install \
    \
      behave==1.2.6 \
      pymongo==3.9.0 \
      requests==2.19.1 \
      ujson==1.35 \
      docker==3.7.0 \
      pyzmq==18.0.2 \
      matplotlib==2.2.2 \
      scipy==1.3.0 \
      numpy==1.16.4 \
      pynng==0.4.0 \
      behave2cucumber==1.0.3 \
    && \
    :

RUN \
    sed -i '/imklog/{s/^/#/}' /etc/rsyslog.conf && \
    sed -ri /etc/systemd/journald.conf -e 's!^#?Storage=.*!Storage=volatile!' && \
    \
    systemctl mask -- \
      tmp.mount \
      etc-hostname.mount \
      etc-hosts.mount \
      etc-resolv.conf.mount \
      -.mount \
      getty.target \
      getty-static.service \
      dev-mqueue.mount \
      cgproxy.service \
      apt-daily.service \
      systemd-tmpfiles-setup-dev.service \
      systemd-timesyncd.service \
      systemd-timedated.service \
      systemd-ask-password-wall.path \
      systemd-logind.service && \
    \
    echo "root:Docker!" | chpasswd && \
    \
    rm -f \
      /lib/systemd/system/multi-user.target.wants/* \
      /etc/systemd/system/*.wants/* \
      /lib/systemd/system/local-fs.target.wants/* \
      /lib/systemd/system/sockets.target.wants/*udev* \
      /lib/systemd/system/sockets.target.wants/*initctl* \
      /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
      /lib/systemd/system/systemd-update-utmp* && \
    \
    (systemctl set-default multi-user.target || :) && \
    (systemctl enable mongod || :)

COPY --from=arm64/docker:18 /usr/local/bin/docker /usr/bin/docker

WORKDIR /opt/bbtest

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock" ]

ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
