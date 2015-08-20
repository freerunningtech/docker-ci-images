# This is run as root and is expected to setup all desired rubies
set -ex

# Install chruby
curl -Lo chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install
cd /
rm -Rf chruby-*

# Install ruby-install
curl -Lo ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
tar -xzvf ruby-install-0.5.0.tar.gz
cd ruby-install-0.5.0/
make install
cd /
rm -Rf ruby-install-*

# Install our rubies
export MAKEFLAGS="-j4"

#for ruby_version in 2.2.3 2.2.2 2.1.6; do
for ruby_version in 2.2.2; do
	ruby-install ruby "$ruby_version" -- --disable-install-rdoc
	(
	. /usr/local/share/chruby/chruby.sh
	chruby "$ruby_version"
	gem install --no-ri --no-rdoc bundler
	)
done
