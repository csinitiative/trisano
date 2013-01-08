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

require File.dirname(__FILE__) + '/../spec_helper'

describe Privilege do
  before(:each) do
    @privilege = Privilege.new
  end

  it "should be valid" do
    @privilege.should be_valid
  end

  it "name should return translated version of priv_name" do
    @privilege.priv_name = "add_form_to_event"
    @privilege.name.should == "Add forms to events"
  end

  describe "using convenience finders" do
    fixtures :privileges

    it "should find the update event privilege" do
      Privilege.update_event.id.should == privileges(:update).id
    end

    it "should find the investigate event privilege" do
      Privilege.investigate_event.id.should == privileges(:investigate_event).id
    end
  end

end
