if [ -n "$XVFB" ]; then
	Xvfb :99 -ac 1024x768x24 >/dev/null 2>&1 &
	export DISPLAY=:99
fi

if [ -n "$POSTGRESQL" ]; then
	service postgresql start
	createuser -U postgres -s root
fi

if [ -n "$INTERACTIVE" ]; then
	/bin/bash
else
	sh ci_run.sh
fi
