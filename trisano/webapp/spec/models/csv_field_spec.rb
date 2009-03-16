require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CsvField do
  before(:each) do
    @valid_attributes = {
      :long_name  => 'long_name_field_stuff',
      :short_name => 'short_name',
      :evaluation => 'some_script',
      :group      => 'event',
      :event_type => 'morbidity_event',
      :sort_order => 10
    }
  end

  it "should create a new instance given valid attributes" do
    CsvField.create!(@valid_attributes)
  end

  it "should raise an error if short_name is longer then 10 chars" do
    csv_field = CsvField.new(@valid_attributes.merge(:short_name => 'this name is too long'))
    csv_field.should_not be_valid
  end
    
end
