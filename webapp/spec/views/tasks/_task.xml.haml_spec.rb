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

describe "/tasks/_task.xml.haml" do
  before do
    @event = Factory.create(:event_with_task)
    @task = @event.tasks.first
    render '/tasks/_task.xml.haml', :locals => { :task => @task }
  end

  it "should have event task fields" do
    [:name,
     :notes,
     :priority,
     :due_date,
     :repeating_interval,
     :until_date,
     %w(category_id https://wiki.csinitiative.com/display/tri/Relationship+-+TaskCategory),
    ].each do |field, rel|
      assert_xml_field("task", field, rel)
    end
  end
end
