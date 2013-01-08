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

describe CsvField do
  before(:each) do
    @valid_attributes = {
      :long_name       => 'long_name_field_stuff',
      :short_name      => 'short_name',
      :use_description => 'some_script',
      :use_code        => 'some other script',
      :export_group    => 'event',
      :event_type      => 'morbidity_event',
      :sort_order      => 10
    }
  end

  it { should belong_to(:core_field) }
  
  it "should create a new instance given valid attributes" do
    CsvField.create!(@valid_attributes)
  end

  it "should raise an error if short_name is longer then 10 chars" do
    csv_field = CsvField.new(@valid_attributes.merge(:short_name => 'this name is too long'))
    csv_field.should_not be_valid
  end
    
end
