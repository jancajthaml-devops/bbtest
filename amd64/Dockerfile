# Copyright (c) 2017-2020, Jan Cajthaml <jan.cajthaml@gmail.com>
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

FROM amd64/debian:buster

LABEL com.circleci.preserve-entrypoint=true

ENV LANG C.UTF-8
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE no

RUN \
  apt-get update -y && \
  \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    tar \
    cron \
    bzip2 \
    apt-utils \
    dpkg-dev \
    netcat-openbsd \
    build-essential \
    rsyslog \
    multiarch-support \
    libzmq5>=4.3.1~ \
    libzmq3-dev>=4.3.1~ \
    openjdk-11-jre \
    python3 \
    python3-dev \
    python3-wheel \
    python3-pip \
    python3-setuptools \
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
      behave==1.2.6 \
      psycopg2-binary==2.8.3 \
      requests==2.19.1 \
      ujson==1.35 \
      docker==3.7.0 \
      pyzmq==19.0.0 \
      matplotlib==2.2.2 \
      scipy==1.3.0 \
      numpy==1.16.4 \
      pynng==0.4.0 \
      behave2cucumber==1.0.3 \
      cucumber-json-to-junit-xml==0.0.10 \
    && \
    :

RUN \
    sed -i '/imklog/{s/^/#/}' /etc/rsyslog.conf && \
    sed -ri /etc/systemd/journald.conf -e 's!^#?Storage=.*!Storage=volatile!' && \
    printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d

RUN systemctl mask -- \
      dev-hugepages.mount \
      sys-fs-fuse-connections.mount \
      systemd-tmpfiles-setup-dev.service \
      systemd-firstboot.service \
      systemd-udevd.service \
      systemd-resolved.service \
      systemd-ask-password-wall.path \
      systemd-logind.service && \
    :

RUN rm -f \
      /etc/machine-id \
      /var/lib/dbus/machine-id && \
    :

COPY --from=amd64/docker:18 /usr/local/bin/docker /usr/bin/docker

STOPSIGNAL SIGRTMIN+3

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock" ]

ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/sbin/init" ]
