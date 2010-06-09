#!/bin/bash

# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

# install the .gem files that are required to run the system

. setenv.sh

GEM_DIR=../lib/gems/

echo "installing gems"
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/jruby-openssl-0.2.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activerecord-jdbc-adapter-0.9.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activerecord-jdbcpostgresql-adapter-0.9.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/jdbc-postgres-8.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/builder-2.1.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hpricot-0.6-java.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hpricot-0.6.161-java.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyforge-1.0.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hoe-1.7.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/mechanize-0.7.6.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/ci_reporter-1.5.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rest-open-uri-1.0.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/warbler-0.9.14.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/jruby-jars-1.4.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/flexmock-0.8.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/lockfile-1.4.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/logging-1.3.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/little-plugger-1.1.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/json_pure-1.1.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyzip-0.9.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/mislav-will_paginate-2.3.6.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rspec-1.2.8.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rspec-rails-1.2.7.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/haml-2.0.7.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rack-1.0.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rails-2.3.5.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activesupport-2.3.5.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activeresource-2.3.5.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activerecord-2.3.5.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/actionpack-2.3.5.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/actionmailer-2.3.5.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/ruby-hl7-0.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/faker-0.3.1.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/factory_girl-1.2.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/freshy_filter_chain-0.1.0.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/validates_timeliness-2.2.2.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/mocha-0.9.8.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/webrat-0.7.2.pre.gem
