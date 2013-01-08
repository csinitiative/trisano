# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
require 'spec_helper'

describe "events/_lab.html.haml" do

  it "should not show deleted labs in the labs drop down" do
    lab_entity = find_or_create_lab_by_name('Labmart')
    deleted = find_or_create_lab_by_name('Labgreens')
    deleted.update_attribute('deleted_at', DateTime.now)
    event = assigns(:event)
    event.stubs(:id => 1) 

    render "events/_lab.html.haml", :locals => { :prefix => 'pffft_event', :uniq_id => 'TEST', :lab => Lab.new }
    response.should have_tag('option', lab_entity.place.name)
    response.should_not have_tag('option', deleted.place.name)
  end
end
