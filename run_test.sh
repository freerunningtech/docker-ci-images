#!/bin/bash

set -e

. /usr/local/share/chruby/chruby.sh
if [ -n "$RUBY" ]; then
	# Use the ruby version asked for
	chruby "$RUBY"
elif [ -e ".ruby-version" ]; then
	# Autodetect a ruby version
	. /usr/local/share/chruby/auto.sh
	chruby_auto
else
	# Use a modern default
	chruby 2.2.2
fi

if [ -n "$1"  ]; then
	exec "$@"
elif [ -e ".ci.sh"  ]; then
	set -x
	. .ci.sh
else
	set -x
	. ci_run.sh
fi
