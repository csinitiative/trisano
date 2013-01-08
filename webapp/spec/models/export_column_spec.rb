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

describe ExportColumn do
  before(:each) do
    @export_column = ExportColumn.new
  end

  it "should not be valid" do
    @export_column.should_not be_valid
  end

  it "should validate required fields for form type data" do
    @export_column.type_data = "FORM"
    @export_column.table_name = "some_table"
    @export_column.column_name = "some_column"
    @export_column.save
    @export_column.errors.on(:base).sort.should == [
      "Data Type required if Data Source is Formbuilder",
      "Table Name must be blank if Data Source is Formbuilder",
      "Column Name must be blank if Data Source is Formbuilder"
      ].sort
  end

  it "should validate required fields for CORE type data" do
    @export_column.type_data = "CORE"
    @export_column.save
    @export_column.errors.on(:base).sort.should == [
      "Table Name required if Data Source is Core",
      "Column Name required if Data Source is Core"].sort
  end

  it "should validate required fields for FIXED type data" do
    @export_column.type_data   = "FIXED"
    @export_column.data_type   = "some type"
    @export_column.table_name  = "some table"
    @export_column.column_name = "some column"
    @export_column.save
    @export_column.errors.on(:base).sort.should == [
      "Data Type must be blank if Data Source is System Generated",
      "Table Name must be blank if Data Source is System Generated",
      "Column Name must be blank if Data Source is System Generated"
    ].sort
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

  describe 'core_export_columns_for' do
    fixtures :diseases, :export_names

    before(:each) do
      ec = ExportColumn.create(:type_data => 'CORE',
                               :name => 'Sample Export Column',
                               :length_to_output => 1,
                               :start_position => 75,
                               :table_name => 'events',
                               :column_name => 'event_onset_date',
                               :export_column_name => 'sample_export_column',
                               :export_name_id => 1)
      ec.diseases << diseases(:aids)
      ec.save!
    end

    it 'should return an empty array if no diseases are passed' do
      ExportColumn.core_export_columns_for(nil).should be_empty
    end

    it 'should return an empty array if an empty list of disease ids are passed' do
      ExportColumn.core_export_columns_for([]).should be_empty
    end

    it 'should only return export columns associated w/ disease ids' do
      ecs = ExportColumn.core_export_columns_for([4])
      ecs.size.should == 1
      ecs.each do |ec|
        ec.diseases.each {|d| d.disease_name.should == 'AIDS'}
      end
    end

  end
end
