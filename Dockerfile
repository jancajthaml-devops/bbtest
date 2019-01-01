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

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    PYTHON_VERSION=3.7.1 \
    RUBY_MAJOR=2.5 \
    RUBY_VERSION=2.5.3 \
    RUBYGEMS_VERSION=2.7.8 \
    BUNDLER_VERSION=1.17.1 \
    BUNDLE_PATH=/usr/local/ruby \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG=/usr/local/ruby

RUN apt-get update && \
    \
    apt-get install -y --no-install-recommends \
      apt-utils \
      ca-certificates>=20161130 \
      && \
    \
    apt-get -y install --no-install-recommends \
      at \
      autoconf \
      bison \
      tar \
      bzip2 \
      cron \
      curl \
      tk-dev \
      uuid-dev \
      dirmngr \
      dpkg-dev \
      gcc \
      git \
      gnupg \
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
      libzmq3-dev=4.2.1-4 \
      logrotate \
      lsb-release \
      lsof \
      make \
      netcat-openbsd \
      procps \
      rsyslog \
      ruby \
      ssmtp \
      systemd \
      sysvinit-utils \
      udev \
      util-linux \
      xz-utils \
      zlib1g-dev \
      && \
    \
    sed -i '/imklog/{s/^/#/}' /etc/rsyslog.conf && \
    \
    curl -sL https://deb.nodesource.com/setup_10.x | bash && \
    \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | \
      tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    \
    apt-get update && \
    \
    mkdir -p /usr/local/etc /usr/src/ruby /usr/local/ruby && \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc && \
    \
    curl -sL "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-${RUBY_VERSION}.tar.xz" | tar xJf - --strip-components=1 -C /usr/src/ruby && \
    \
    cd /usr/src/ruby && \
    autoconf && \
    ./configure \
      --build=x86_64-linux-gnu \
      --disable-install-doc \
      --enable-shared && \
    make && \
    make install && \
    cd / && \
    gem update --system ${RUBYGEMS_VERSION} && \
    rm -r /root/.gem/ /usr/src/ruby && \
    \
    gem install \
      \
        bigdecimal:1.3.4 \
        byebug:10.0.1 \
        ffi-rzmq:2.0.4 \
        mongo:2.6.2 \
        rspec:3.8 \
        rspec_junit_formatter:0.3.0 \
        rspec-instafail:1.0.0 \
        turnip:2.1.1 \
        turnip_formatter:0.5.0 \
        json-diff:0.4.1 \
    && \
    \
    mkdir -p /usr/local/etc /usr/src/python /usr/local/python && \
    \
    curl -sL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" | tar xJC - --strip-components=1 -C /usr/src/python && \
    \
    cd /usr/src/python && \
    autoconf && \
    ./configure \
      --build=x86_64-linux-gnu \
      --with-system-expat \
      --enable-shared && \
    make && \
    make install && \
    cd / && \
    ldconfig && \
    \
    find /usr/local -depth \
      \( \
        \( -type d -a \( -name test -o -name tests \) \) \
        -o \
        \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
      \) -exec rm -rf '{}' + && \
    rm -rf /usr/src/python && \
    \
    pip3 install \
    \
      requests==2.19.1 \
      ujson==1.35 \
      inotify_simple \
      && \
    \
    cd /lib/systemd/system/sysinit.target.wants/ && \
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
    echo "root:Docker!" | chpasswd && \
    \
    rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/ruby/bin:${BUNDLE_PATH}/gems/bin:${PATH}

WORKDIR /opt/bbtest

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]

ENTRYPOINT ["/lib/systemd/systemd"]
