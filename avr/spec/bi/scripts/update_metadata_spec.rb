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

require 'update_metadata'

describe 'updating metadata' do

  before :all do
    @metadata_file = File.expand_path File.join(File.dirname(__FILE__), '../../../bi/schema/metadata.xmi')
    File.exist?(@metadata_file).should be_true
    @metadata = load_metadata_xmi(@metadata_file)
  end
  
  it 'should be able to create a category name' do
    @metadata.category_name('bacterial_meningitis_other').should == 'Bacterial Meningitis Other'
  end

  it 'should be able to list concepts' do
    @metadata.concept_names.size.should > 0
  end

  it 'should have a Base concept' do
    @metadata.base_concept.should_not be_nil
  end

  it 'should do nothing if no tables have been modified' do
    mock_block = mock('None block')
    mock_block.should_receive(:call)
    @metadata.publish [], {:none => mock_block}
  end

  describe 'TriSano Business model' do

    it 'should find morbidity event table' do
      @metadata.morbidity_events_table.should_not be_nil
    end

    it 'should find contact events table' do
      @metadata.contact_events_table.should_not be_nil
    end

  end

  describe 'Business Tables' do
    
    it 'should guess id columns for tables' do
      @metadata.morbidity_events_table.id_column.get_id.should == 'BC_DW_MORBIDITY_EVENTS_VIEW_ID'
    end

  end

  describe 'Physical Tables' do

    before :each do
      @mock_db = mock('writable database')
      @metadata.should_receive(:writable_database).and_return(@mock_db)
    end
    
    it 'should have physical columns' do
      @mock_db.should_receive(:column_names_for).with('test_table').and_return %w(event_id type col_test_column)
      @metadata.update_physical_table('test_table')
      @metadata.find_physical_table('test_table_view').should_not be_nil
      @metadata.find_physical_table('test_table_view').physical_columns.size.should == 3
    end

    describe 'physical columns' do
      before :each do
        @mock_db.should_receive(:column_names_for).with('test_table').and_return %w(event_id type test_column)
        @metadata.update_physical_table('test_table')
        @physical_table = @metadata.find_physical_table('test_table_view')
      end
        
      it 'should exist' do
        @physical_table.physical_columns.size.should > 0
      end

      describe ': event_id' do
        before :each do
          @column = @physical_table.find_physical_column('event_id')
        end
        
        it 'should exist' do
          @column.should_not be_nil
        end

        it 'should have a data type \'Numeric\'' do
          @column.data_type.should == Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings::NUMERIC
        end

        it 'should have a formula' do
          @column.formula.should == 'event_id'
        end

        it 'should be a dimension' do
          @column.field_type.should == Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
        end
      end

      describe ': type' do
        before :each do
          @column = @physical_table.find_physical_column('type')
        end
        
        it 'should exist' do
          @column.should_not be_nil
        end

        it 'should have a data type \'String\'' do
          @column.data_type.should == Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings::STRING
        end

        it 'should have a formula' do
          @column.formula.should == 'type'
        end

        it 'should be a dimension' do
          @column.field_type.should == Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
        end
      end
      
      describe 'all other columns' do
        before :each do
          @column = @physical_table.find_physical_column('test_column')
        end
        
        it 'should exist' do
          @column.should_not be_nil
        end

        it 'should have data type \'String\'' do
          @column.data_type.should == Java::OrgPentahoPmsSchemaConceptTypesDatatype::DataTypeSettings::STRING
        end

        it 'should have a formula that include \'col\'' do
          @column.formula.should == 'col_test_column'
        end

        it 'should be dimensions' do
          @column.field_type.should == Java::OrgPentahoPmsSchemaConceptTypesFieldtype::FieldTypeSettings::DIMENSION
        end

        it 'should have a concept name' do
          @column.concept.name.should == 'test_column'
        end

        it 'should have a table reference' do
          @column.table.should_not be_nil
        end
        
        it 'should have a name property' do
          @column.concept.get_property('name').should_not be_nil
        end

        it 'should have a name property set to the column id' do
          @column.concept.get_property('name').value.locale_string_map['en_US'].should == 'test column'
        end
      end
    end
  end

end
