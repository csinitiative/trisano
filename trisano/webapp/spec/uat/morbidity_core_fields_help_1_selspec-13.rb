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

require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/morbidity_core_fields_help_base'

describe "help text for morbidity core fields" do
  #   $dont_kill_browser = true
  
  core_fields = YAML::load_file(File.join(File.dirname(__FILE__), '..', '..', 'db', 'defaults', 'core_fields.yml'))

  $test_core_fields = core_fields.collect{ |k,v| v }.select{|f| f['event_type'] == 'morbidity_event'}[0,10]
  
  it_should_behave_like "help text for morbidity core fields"
end
