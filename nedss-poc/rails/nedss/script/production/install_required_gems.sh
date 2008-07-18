#!/bin/bash

# install the .gem files that are required to run the system

GEM_DIR=/home/mike/gems

echo "installing gems"
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/jruby-openssl-0.2.3.gem
#jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyforge-0.4.5.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/postgres-pr-0.4.0.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/builder-2.1.2.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/activesupport-2.0.2.gem
# unclear on who has dependency on active-support 2.1.0 this - jetty-rails?
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/activesupport-2.1.0.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/actionpack-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc -f $GEM_DIR/activeresource-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/actionmailer-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/activerecord-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/rails-2.0.2.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/ci_reporter-1.5.1.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/mechanize-0.7.5.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/rest-open-uri-1.0.0.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/hoe-1.5.1.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/hpricot-0.6.161-java.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/jetty-rails-0.5.gem
jruby -S gem install --no-ri --no-rdoc $GEM_DIR/warbler-0.9.9.gem
