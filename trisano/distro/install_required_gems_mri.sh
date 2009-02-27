#!/bin/bash

# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/jruby-openssl-0.2.3.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/postgres-pr-0.4.0.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/builder-2.1.2.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activesupport-2.0.5.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/actionpack-2.0.5.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activeresource-2.0.5.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/actionmailer-2.0.5.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/activerecord-2.0.5.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rails-2.0.5.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hpricot-0.6.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyforge-1.0.0.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/hoe-1.7.0.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/mechanize-0.7.6.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/ci_reporter-1.5.1.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rest-open-uri-1.0.0.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/warbler-0.9.12.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/flexmock-0.8.3.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/lockfile-1.4.3.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/logging-0.9.4.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/json_pure-1.1.3.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rubyzip-0.9.1.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/mislav-will_paginate-2.3.6.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rspec-1.1.12.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/rspec-rails-1.1.12.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/haml-2.0.7.gem
sudo gem install --no-ri --no-rdoc --ignore-dependencies $GEM_DIR/cucumber-0.1.16.gem
