FROM ruby:2.2.2

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    apt-get install -y locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.utf8

RUN apt-get -y install --no-install-recommends \
    build-essential \
    git-core \
    curl libssl-dev \
    libreadline-dev \
    zlib1g zlib1g-dev \
    libcurl4-openssl-dev \
    libxslt-dev libxml2-dev \
    xvfb nodejs \
    postgresql \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/md5\|peer/trust/' /etc/postgresql/*/main/pg_hba.conf

RUN gem install --no-ri --no-rdoc rubygems-update && \
    update_rubygems --no-ri --no-rdoc && \
    gem install --no-ri --no-rdoc bundler && \
    bundle config --global path /cache/ && \
    bundle config --global jobs 8

ENV BUNDLE_GEMFILE /workspace/Gemfile

ADD phantomjs /usr/local/bin/phantomjs
ADD init.sh /
CMD sh /init.sh
