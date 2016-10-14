#!/bin/bash
#
# Run as root as the entry point of the container
# It should setup the necessary services, create and switch to the ci user, and
# start the rest of the build.

set -e

# We want to have the same UID as the user on the host system
CI_UID=$(stat -c "%u" /workspace)
useradd ci -u "$CI_UID" -d /cache
chown ci:ci /cache

if [ -n "$POSTGRESQL" ]; then
	# Make PostgreSQL YOLOFAST
	# Suggestions from http://stackoverflow.com/questions/9407442/optimise-postgresql-for-fast-testing
	sed -i 's/md5\|peer/trust/' /etc/postgresql/*/main/pg_hba.conf
	cat >> /etc/postgresql/9.3/main/postgresql.conf <<EOF
fsync=off
full_page_writes=off
synchronous_commit=off
EOF

	service postgresql start
	createuser -U postgres -s ci
	createdb -U postgres ci
	export DATABASE_URL=postgresql:///ci
fi

if [ -n "$MYSQL" ]; then
	# Make MySQL YOLOFAST
	# Based on http://www.tocker.ca/2013/11/04/reducing-mysql-durability-for-testing.html
	cat > /etc/mysql/conf.d/unsafe_but_fast.cnf <<EOF
[mysqld]
sync_frm=0
innodb-flush-log-at-trx-commit=0
innodb_flush_method=nosync
innodb-doublewrite=0
innodb-checksums=0
innodb_support_xa=0
sync_binlog=0
EOF

	service mysql start
	mysql -uroot -e "create database ci"
	export DATABASE_URL=mysql2:///ci
fi

if [ -n "$MEMCACHED" ]; then
	service memcached start
fi

if [ -n "$REDIS" ]; then
	service redis-server start
fi

if [ -n "$ELIXIR" ]; then
	mkdir -p /opt/elixir
	curl -Lo /tmp/elixir.zip "https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR/Precompiled.zip"
	unzip -qq /tmp/elixir.zip -d /opt/elixir
	export PATH="$PATH:/opt/elixir/bin"
	export MIX_ENV=test
	rm /tmp/elixir.zip
	gosu ci mix local.hex --force
	gosu ci mix local.rebar --force
fi

if [ -n "$XVFB" ]; then
	gosu ci Xvfb :99 -ac >/dev/null 2>&1 &
	export DISPLAY=:99
fi

export GEM_HOME=/cache
export BUNDLE_APP_CONFIG=/cache
export RAILS_ENV=test RACK_ENV=test

cat > "$BUNDLE_APP_CONFIG/config" <<EOF
BUNDLE_MIRROR__HTTPS://RUBYGEMS__ORG/: https://gems.stembolt.io/
BUNDLE_MIRROR__HTTP://RUBYGEMS__ORG/: https://gems.stembolt.io/
EOF

# Restore node_modules from our cache, if we have one.
if [ -d /cache/node_modules ] ; then
	rm -fr /workspace/node_modules
	cp -a /cache/node_modules /workspace/node_modules
	chown -R ci /workspace/node_modules
fi

gosu ci bash /run_test.sh "$@"
STATUS=$?

# Copy node_modules out of workspace so we don't have to do a full install
# every time.
if [ -d /workspace/node_modules ] ; then
	rm -fr /cache/node_modules
	cp -a /workspace/node_modules /cache/node_modules
	chown -R ci /cache/node_modules
fi

exit $STATUS
