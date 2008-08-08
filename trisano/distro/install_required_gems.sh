#!/bin/bash
# consider shipping jruby as well and renaming this to configure_jruby.sh
# script would tar xvf jruby, set path, and install the gems
# this would make the dist pretty mistake proof at least at the setup level
# total size of distro would be 30MB which isn't too bad

# install the .gem files that are required to run the system

GEM_DIR=../lib/gems/

echo "installing gems"
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/jruby-openssl-0.2.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/postgres-pr-0.4.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/builder-2.1.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activesupport-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/actionpack-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activeresource-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/actionmailer-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activerecord-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rails-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hpricot-0.6-java.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hpricot-0.6.161-java.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyforge-1.0.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hoe-1.7.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/mechanize-0.7.6.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/ci_reporter-1.5.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rest-open-uri-1.0.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/warbler-0.9.9.gem
