# docker-ci-images

Docker images for running CI tests in isolated containers.

For now this is a single image.

## Environment Options

| Key | Possible Values | Description |
| --- | --------------- | ----------- |
| MYSQL | 1 | Starts MySQL Server |
| POSTGRESQL | 1 | Starts PostgreSQL Server |
| MEMCACHED | 1 | Starts memcached Server |
| XVFB | 1 | Starts Xvfb on display :99 |
| ELIXIR | 1.0.5 | Installs elixir 1.0.5 including hex and rebar |
| RUBY | 2.2.2 | Switches to ruby 2.2.2 before running `ci_run.sh` |

## Example Usage

in [porkchop](http://github.com/freerunningtech/porkchop)'s work directory


``` shell
cat > ci_run.sh <<EOF
bundle install
bundle exec rake db:test:prepare
bundle exec rspec
EOF
docker run --rm -v `pwd`:/workspace -v /tmp/porkchop_cache:/cache -e POSTGRESQL=1 freerunning/frt-ci
```

## Advanced Usage

If you specify additional arguments after the image, they will be interpreted as commands to run instead of the run_test script. The following will drop you in a shell as the ci user (ENV however, will not be setup correctly).

```
docker run --rm -v `pwd`:/workspace -v /tmp/porkchop_cache:/cache -e POSTGRESQL=1 freerunning/frt-ci /bin/bash
```

If instead you want to run commands as the root user, before services have been started, the ENTRYPOINT can be overridden

```
docker run --rm -v `pwd`:/workspace -v /tmp/porkchop_cache:/cache -e POSTGRESQL=1 --entrypoint=/bin/bash freerunning/frt-ci
```
