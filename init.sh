# Run as root as the entry point of the container
# It should setup the necessary services, create and switch to the ci user, and
# start the rest of the build.

if [ -n "$XVFB" ]; then
	Xvfb :99 -ac 1024x768x24 >/dev/null 2>&1 &
	export DISPLAY=:99
fi

if [ -n "$POSTGRESQL" ]; then
	service postgresql start
	createuser -U postgres -s ci
fi

if [ -n "$MYSQL" ]; then
	service mysql start
fi

# We want to have the same UID as the user on the host system
CI_UID=$(stat -c "%u" /workspace)
useradd ci -u "$CI_UID" -d /cache
chown ci:ci /cache

su -c "
. /usr/local/share/chruby/chruby.sh
. /usr/local/share/chruby/auto.sh
chruby 2.2.3
chruby_auto
. ci_run.sh
" ci
