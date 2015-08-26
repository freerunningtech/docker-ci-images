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

RUN npm install -g coffee phantomjs svgo karma-cli

ADD install_rubies.sh /
RUN bash install_rubies.sh && \
    rm -Rf /usr/local/src/*

RUN sed -i 's/md5\|peer/trust/' /etc/postgresql/*/main/pg_hba.conf && \
    printf "# Evil performance options\nfsync=off\n#full_page_writes=off\nsynchronous_commit=off\n" >> /etc/postgresql/9.3/main/postgresql.conf

CMD sh /init.sh
ADD init.sh run_test.sh /
