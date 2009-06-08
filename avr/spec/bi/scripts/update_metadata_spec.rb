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

    it 'should not add a column if it already exists'

  end

end
