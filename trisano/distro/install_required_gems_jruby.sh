#!/bin/bash

# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/flexmock-0.8.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/lockfile-1.4.3.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/logging-0.9.4.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/json-jruby-1.1.2-universal-java.gem
jruby -S gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyzip-0.9.1.gem

