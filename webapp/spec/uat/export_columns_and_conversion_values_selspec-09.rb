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

require File.dirname(__FILE__) + '/spec_helper'
 
# $dont_kill_browser = true

describe 'adding an export column' do
  
  before(:all) do
    @descriptive_name = get_unique_name(2)
  end
  
  after(:all) do
  end

  it 'should create a new export column' do
    @cdc_name = get_unique_name(1)
    table_name = get_unique_name(1)
    column_name = get_unique_name(1)

    navigate_to_export_admin(@browser).should be_true
    @browser.click("//input[@value='Create new Export Column']")
    @browser.wait_for_page_to_load($load_time)

    #associate some diseases
    %w(Hepatitis_A Hepatitis_B,_acute Hepatitis_B_virus_infection,_chronic).each do |id|
      @browser.check("css=input[id^='#{id}']")
    end

    @browser.type("export_column_name", @descriptive_name)
    @browser.type("export_column_export_column_name", @cdc_name)
    @browser.select "export_column_export_disease_group_id", "label=Hepatitis"
    @browser.select "export_column_export_disease_group_id", "label=Hepatitis"
    @browser.select "export_column_type_data", "label=Core Data"
    @browser.type "export_column_table_name", table_name
    @browser.type "export_column_column_name", column_name
    @browser.type "export_column_start_position", "1"
    @browser.type "export_column_length_to_output", "3"

    @browser.click "export_column_submit"
    @browser.wait_for_page_to_load($load_time)

    @browser.is_text_present("Export Column was successfully created.").should be_true
    ['Hepatitis A','Hepatitis B, acute','Hepatitis B virus infection, chronic'].each do |text|
      @browser.is_text_present(text).should be_true
    end
    @browser.is_text_present(@descriptive_name).should be_true
    @browser.is_text_present(@cdc_name).should be_true
    @browser.is_text_present(table_name).should be_true
    @browser.is_text_present(column_name).should be_true
  end

  it "should allow editing of an export column" do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load($load_time)
    @browser.uncheck("css=input[id='Hepatitis_A']")
    @browser.type("export_column_name", @descriptive_name)
    @browser.click "export_column_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Hepatitis A').should_not be_true
    @browser.is_text_present("Export Column was successfully updated.").should be_true
    @browser.is_text_present(@descriptive_name).should be_true
  end

  it "should allow adding an export conversion value" do
    @browser.click "link=Add a conversion value"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "export_conversion_value_value_from", "One"
    @browser.type "export_conversion_value_value_to", "1"
    @browser.click "export_conversion_value_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("Export Conversion Value was successfully created.").should be_true
  end

  it "should allow editing an export conversion value" do
    @browser.click("//table[4]//a[1]") # The first link in the third table is the Edit conversion value link.  Yeah, I know.
    @browser.wait_for_page_to_load($load_time)
    @browser.type "export_conversion_value_value_to", "999"
    @browser.click "export_conversion_value_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("Export Conversion Value was successfully updated.").should be_true
    @browser.is_text_present("999").should be_true
  end

  it "should allow deleting of an export conversion value" do
    @browser.click("//table[4]//a[2]") # The second link in the third table is the Delete conversion value link.  Yeah, I know.
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("999").should_not be_true
  end

  it "should allow deleting of an export conversion value" do
    @browser.click "link=Delete"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("Export Columns").should be_true
    @browser.is_text_present(@cdc_name).should be_true
  end
end
  
