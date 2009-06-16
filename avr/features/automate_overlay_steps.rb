require 'spec/expectations'
require 'spec/matchers'
require File.expand_path File.join(File.dirname(__FILE__), '..', 'bi', 'scripts', 'update_metadata')

Before do
  puts "Running"
end


After do
  @metadata.writable_database.execute("DELETE FROM trisano.formbuilder_columns WHERE formbuilder_table_name = 'formbuilder_test_table_1';")
  @metadata.writable_database.execute("DELETE FROM trisano.formbuilder_tables WHERE table_name = 'formbuilder_test_table_1';")
  @metadata.writable_database.execute("DROP TABLE trisano.formbuilder_test_table_1_view;")
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
