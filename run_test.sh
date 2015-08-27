set -e

if [ -n "$ELIXIR" ] ;then
	export PATH="$PATH:/opt/elixir/bin"
	export MIX_ENV=test
	mix local.hex --force
	mix local.rebar --force
fi

export GEM_HOME=/cache
export BUNDLE_APP_CONFIG=/cache

export RAILS_ENV=test RACK_ENV=test

. /usr/local/share/chruby/chruby.sh
. /usr/local/share/chruby/auto.sh
if [ -n "$RUBY" ]; then
	# Use the ruby version asked for
	chruby "$RUBY"
else
	# Try to autodetect a ruby
	chruby 2.2.2 || true
	chruby_auto || true
fi

if [ -n "$POSTGRESQL" ]; then
	export DATABASE_URL=postgresql://ci@localhost/ci
fi

set -x
if [ -e ".ci.sh"  ]; then
	. .ci.sh
else
	. ci_run.sh
fi
