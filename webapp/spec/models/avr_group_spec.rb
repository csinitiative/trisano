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
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AvrGroup do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    AvrGroup.create!(@valid_attributes)
  end

  it "should not be valid without a name" do
    AvrGroup.create(:name => '').errors.on(:name).should == "can't be blank"
  end

  it 'should have a unique name' do
    AvrGroup.create(:name => 'Lurgies')
    AvrGroup.create(:name => 'Lurgies').errors.on(:name).should == "has already been taken"
  end


end
