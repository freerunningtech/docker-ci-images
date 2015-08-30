#!/bin/bash
#
# Run as root as the entry point of the container
# It should setup the necessary services, create and switch to the ci user, and
# start the rest of the build.

set -e

if [ -n "$XVFB" ]; then
	Xvfb :99 -ac 1024x768x24 >/dev/null 2>&1 &
	export DISPLAY=:99
fi

if [ -n "$POSTGRESQL" ]; then
	sed -i 's/md5\|peer/trust/' /etc/postgresql/*/main/pg_hba.conf
	printf "fsync=off\n#full_page_writes=off\nsynchronous_commit=off\n" >> /etc/postgresql/9.3/main/postgresql.conf

	service postgresql start
	createuser -U postgres -s ci
	createdb -U postgres ci
fi

if [ -n "$MYSQL" ]; then
	service mysql start
	mysql -uroot -e "create database ci"
fi

if [ -n "$MEMCACHED" ]; then
	service memcached start
fi

if [ -n "$ELIXIR" ]; then
	mkdir -p /opt/elixir
	curl -Lo /tmp/elixir.zip "https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR/Precompiled.zip"
	unzip -qq /tmp/elixir.zip -d /opt/elixir
	export PATH="$PATH:/opt/elixir/bin"
	rm /tmp/elixir.zip
fi

# We want to have the same UID as the user on the host system
CI_UID=$(stat -c "%u" /workspace)
useradd ci -u "$CI_UID" -d /cache
chown ci:ci /cache

su -c "bash /run_test.sh" ci
