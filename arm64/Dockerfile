# Copyright (c) 2017-2022, Jan Cajthaml <jan.cajthaml@gmail.com>
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

FROM --platform=linux/arm64/v8 arm64v8/debian:sid-slim

LABEL com.circleci.preserve-entrypoint=true

ENV LANG C.UTF-8
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE no
ENV UNIFIED_CGROUP_HIERARCHY yes

RUN \
  apt-get update -y && \
  \
  apt-get -y install --no-install-recommends \
    ca-certificates \
    cmake \
    tar \
    bzip2 \
    dpkg-dev \
    faketime \
    build-essential \
    netcat-openbsd \
    rsyslog \
    libpq-dev \
    libfreetype-dev \
    pkg-config \
    libzmq5>=4.3~ \
    libzmq3-dev>=4.3~ \
    openjdk-17-jre \
    python3 \
    python3-dev \
    python3-wheel \
    python3-pip \
    python3-setuptools \
    python3-systemd \
    systemd \
    systemd-sysv \
    dbus \
    dbus-user-session \
  && \
  apt-get clean -y \
  && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/log/alternatives.log \
    /var/log/apt/history.log \
    /var/log/apt/term.log \
    /var/log/dpkg.log \
  :

RUN \
    pip3 install \
    \
      psycopg2-binary==2.9.2 \
      openbank-testkit==0.63 \
      pyzmq==22.3.0 \
      matplotlib \
      ujson \
      scipy \
      numpy \
      pynng \
      pyjks \
      behave==1.2.6 \
      behave2cucumber==1.0.3 \
      behave-plain-color-formatter==0.0.2 \
      cucumber-json-to-junit-xml==0.0.10 \
    && \
    :

RUN \
    sed -i '/imklog/{s/^/#/}' /etc/rsyslog.conf && \
    sed -ri /etc/systemd/journald.conf -e 's!^#?Storage=.*!Storage=volatile!' && \
    printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d

RUN systemctl mask -- \
      dev-hugepages.mount \
      systemd-firstboot.service \
      systemd-udevd.service \
      systemd-resolved.service \
      systemd-ask-password-wall.path \
      systemd-logind.service && \
    :

COPY --from=arm64v8/docker:18 /usr/local/bin/docker /usr/bin/docker

STOPSIGNAL SIGRTMIN+3

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock" ]

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target" ]
