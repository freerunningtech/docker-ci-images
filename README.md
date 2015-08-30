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
docker run --rm -it -v `pwd`:/workspace -v /tmp/porkchop_cache:/cache -w /workspace -e POSTGRESQL=1 freerunning/frt-ci
```
