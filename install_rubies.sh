# This is run as root and is expected to setup all desired rubies
set -ex

# Install chruby
curl -Lo chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install
cd /
rm -Rf chruby-*

RUBY_VERSIONS="2.3.0 2.2.2 2.2.3 2.2.5 2.1.6 2.1.7 2.1.10 2.3.1"
mkdir -p /opt/rubies

for ruby_version in $RUBY_VERSIONS; do
	curl -L "http://rubies.travis-ci.org/ubuntu/14.04/x86_64/ruby-${ruby_version}.tar.bz2" | tar -xjC /opt/rubies/
	(
	. /usr/local/share/chruby/chruby.sh
	chruby "$ruby_version"
	gem install --no-ri --no-rdoc bundler
	)
done
