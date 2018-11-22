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

FROM debian:stretch

RUN dpkg --add-architecture amd64
RUN dpkg --add-architecture armhf

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    RUBY_MAJOR=2.5 \
    RUBY_VERSION=2.5.3 \
    RUBYGEMS_VERSION=2.7.8 \
    BUNDLER_VERSION=1.17.1 \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG=/usr/local/bundle

RUN apt-get -y update && \
    apt-get clean && \
    apt-get -y install \
      apt-utils \
      at \
      autoconf \
      bison \
      bzip2 \
      ca-certificates>=20161130 \
      cron \
      curl \
      dpkg-dev \
      gcc \
      git \
      initscripts \
      libbz2-dev \
      libffi-dev \
      libgdbm-dev \
      libgdbm3 \
      libglib2.0-dev \
      libncurses-dev \
      libreadline-dev \
      libssl-dev \
      libsystemd0 \
      libudev1 \
      libxml2-dev \
      libxslt-dev \
      libyaml-dev \
      libzmq3-dev=4.2.1-4 \
      logrotate \
      lsb-release \
      lsof \
      make \
      procps \
      rsyslog \
      ruby \
      ssmtp \
      systemd \
      sysvinit-utils \
      udev \
      unattended-upgrades \
      util-linux \
      wget \
      xz-utils \
      zlib1g-dev \
  && \
  apt-get clean && \
  sed -i '/imklog/{s/^/#/}' /etc/rsyslog.conf && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN \
  mkdir -p /usr/local/etc /usr/src/ruby mkdir -p ${GEM_HOME} && \
  { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc && \
  \
  curl -L "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-${RUBY_VERSION}.tar.xz" \
    -# \
    -o /tmp/ruby.tar.xz && \
    \
    tar -C /usr/src/ruby --strip-components=1 -xJf /tmp/ruby.tar.xz && \
  \
  cd /usr/src/ruby && \
  autoconf && \
  ./configure \
    --build=x86_64-linux-gnu \
    --disable-install-doc \
    --enable-shared \
  make -j "$(nproc)" && \
  make install && \
  cd / && \
  gem update --system ${RUBYGEMS_VERSION} && \
  rm -r /root/.gem/ /usr/src/ruby

RUN gem install \
    \
      turnip:2.1.1 \
      turnip_formatter:0.5.0 \
      rspec_junit_formatter:0.3.0 \
      rspec-instafail:1.0.0 \
      excon:0.61.0 \
      byebug:10.0.1

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
    ls | grep -v systemd-tmpfiles-setup.service | xargs rm -f && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    systemctl mask -- \
      tmp.mount \
      etc-hostname.mount \
      etc-hosts.mount \
      etc-resolv.conf.mount \
      -.mount \
      swap.target \
      getty.target \
      getty-static.service \
      dev-mqueue.mount \
      cgproxy.service \
      systemd-tmpfiles-setup-dev.service \
      systemd-remount-fs.service \
      systemd-ask-password-wall.path \
      systemd-logind.service && \
    systemctl set-default multi-user.target || : && \
    \
    sed -ri /etc/systemd/journald.conf -e 's!^#?Storage=.*!Storage=volatile!' && \
    echo "root:Docker!" | chpasswd

WORKDIR /opt/bbtest

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]

ENTRYPOINT ["/lib/systemd/systemd"]
