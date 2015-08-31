FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

# We need to update-locale first so that postgres will generate
# the cluster with UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.utf8

RUN apt-get -y install --no-install-recommends \
    build-essential \
    git-core \
    curl libcurl4-openssl-dev libssl-dev \
    libreadline-dev \
    zlib1g zlib1g-dev \
    libyaml-dev libgdbm-dev libncurses5-dev libffi-dev \
    libxslt-dev libxml2-dev \
    nodejs-legacy npm \
    postgresql libpq-dev postgresql-contrib \
    mysql-server libmysqlclient-dev \
    sqlite3 libsqlite3-dev \
    redis-server memcached libmemcache-dev \
    ruby ruby-dev \
    unzip zip \
    xvfb \
    libmagickcore-dev imagemagick libmagickwand-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -Lo /tmp/erlang-repo.deb http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i /tmp/erlang-repo.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends erlang && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g coffee phantomjs svgo karma-cli bower

ADD install_rubies.sh /
RUN bash install_rubies.sh && \
    rm -Rf /usr/local/src/*

RUN curl -Lo /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64 && \
    chmod a+x /usr/local/bin/gosu

WORKDIR /workspace
ENTRYPOINT ["bash", "/init.sh"]
CMD ["bash", "/run_test.sh"]
ADD init.sh run_test.sh /
