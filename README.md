# docker-ci-images

Docker images for running CI tests in isolated containers.

For now this is a single image.

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
