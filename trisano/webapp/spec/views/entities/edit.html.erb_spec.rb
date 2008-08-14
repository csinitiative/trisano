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

require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/person_form_spec_helper'

describe "/people/edit.html.erb" do
  include EntitiesHelper
  include PersonFormSpecHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')

  def do_render
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
    render "/entities/edit.html.erb"
  end

  it_should_behave_like "a person form"

  it "should render edit form" do
    do_render
    response.should have_tag("form[action=#{entity_path(@entity)}][method=post]") do
      with_tag("input[name=?][value=?]", "_method", "put")
    end
  end
end
