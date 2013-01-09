# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013
# The Collaborative Software Foundation
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

require 'spec/expectations'
require 'spec/matchers'
require File.expand_path File.join(File.dirname(__FILE__), '..', 'bi', 'scripts', 'update_metadata')

def remove_file_cruft
  begin
    FileUtils.rm 'metadata.out'
    FileUtils.rm 'metadata.xmi'
    FileUtils.rm 'mdr.btd'
    FileUtils.rm 'mdr.btx'
  rescue 
    puts "Failed to clean up test artifacts"
  end 
end  

Before do
  puts "Running"
end

After do
  @metadata.writable_database.execute("DELETE FROM trisano.formbuilder_columns WHERE formbuilder_table_name = 'formbuilder_test_table_1';")
  @metadata.writable_database.execute("DELETE FROM trisano.formbuilder_tables WHERE table_name = 'formbuilder_test_table_1';")
  @metadata.writable_database.execute("DROP TABLE trisano.formbuilder_test_table_1_view;")
  remove_file_cruft
end


Given /^the core metadata overlay$/ do
  @metadata_file = File.expand_path File.join(File.dirname(__FILE__), '..', 'bi', 'schema', 'metadata.xmi')
  File.exist?(@metadata_file).should be_true
end

Given /^a new formbuilder table$/ do
  @metadata = load_metadata_xmi(@metadata_file)
  @metadata.writable_database.execute("INSERT INTO trisano.formbuilder_tables (short_name, table_name, modified) VALUES ('test_table', 'formbuilder_test_table_1', true);")
  @metadata.writable_database.execute("INSERT INTO trisano.formbuilder_columns (formbuilder_table_name, column_name, orig_column_name) VALUES ('formbuilder_test_table_1', 'test', 'TEST');")
  @metadata.writable_database.execute("CREATE TABLE trisano.formbuilder_test_table_1_view (event_id integer, type text, col_test text);")
end

When /^I run the update script$/ do
  @metadata.update_from_database
end

Then /^I should have a new Physical Table$/ do
  @metadata.find_physical_table('formbuilder_test_table_1_view').should_not be_nil
end

Then /^I should have a new, secured Business Table$/ do
  table = @metadata.trisano_business_model.find_business_table('formbuilder_test_table_1_view')
  table.should_not be_nil
  table.concept.should_not be_nil  
  table.concept.get_property('security').should_not be_nil
  table.business_columns.size.should == 3
end

Then /^I should have a new Relationship$/ do
  relationships = @metadata.trisano_business_model.find_relationships_from(@metadata.trisano_business_model.find_business_table('formbuilder_test_table_1_view'))
  relationships.size.should == 1
  relationships[0].field_to.get_id.should == 'BC_DW_MORBIDITY_EVENTS_VIEW_ID'
  relationships[0].field_from.get_id.should == 'formbuilder_test_table_1_view_event_id'
end

Then /^I should have a new Category$/ do
  category = @metadata.find_business_category('Test Table')
  category.should_not be_nil
  category.business_columns.should_not be_empty
  category.business_columns.size.should == 3
end
