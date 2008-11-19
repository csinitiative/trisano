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

require File.dirname(__FILE__) + '/../spec_helper'

describe ExportColumn do
  before(:each) do
    @export_column = ExportColumn.new
  end

  it "should not be valid" do
    @export_column.should_not be_valid
  end

  it "should require these fields" do
    @export_column.should_not be_valid
    @export_column.should have(1).error_on(:export_name_id)
    @export_column.should have(2).errors_on(:type_data)
    @export_column.should have(1).error_on(:export_column_name)
    @export_column.should have(2).error_on(:start_position)
    @export_column.should have(2).error_on(:length_to_output)

    @export_column.export_name_id = 1
    @export_column.type_data = "FIXED"
    @export_column.export_column_name = "a"
    @export_column.start_position = 1
    @export_column.length_to_output = 1

    @export_column.should be_valid
    @export_column.should have(:no).error_on(:export_name_id)
    @export_column.should have(:no).errors_on(:type_data)
    @export_column.should have(:no).error_on(:export_column_name)
    @export_column.should have(:no).error_on(:start_position)
    @export_column.should have(:no).error_on(:length_to_output)
  end

  it "should validate start position and length on numbers" do
    @export_column.export_name_id = 1
    @export_column.type_data = "FIXED"
    @export_column.export_column_name = "a"
    @export_column.start_position = "a"
    @export_column.length_to_output = "a"

    @export_column.should_not be_valid
    @export_column.should have(1).errors_on(:start_position)
    @export_column.should have(1).errors_on(:length_to_output)

    @export_column.start_position = 1 
    @export_column.length_to_output = 1
    @export_column.should be_valid
  end

  it "should validate that type_data is one of FIXED, CORE, or FORM" do
    @export_column.export_name_id = 1
    @export_column.type_data = "NOTVALID"
    @export_column.export_column_name = "a"
    @export_column.start_position = 1 
    @export_column.length_to_output = 1

    @export_column.should_not be_valid
    @export_column.should have(1).error_on(:type_data)
  end

  it "should test some more validations" do
  end
end
