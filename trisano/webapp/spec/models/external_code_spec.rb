require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalCode do
  before(:each) do
    @external_code = ExternalCode.new
  end

  it "should be valid" do
    @external_code.should be_valid
  end

  describe 'telephone location type ids' do
    
    it 'should be able to provide a list of telephone location type ids' do
      ExternalCode.telephone_location_type_ids.should_not be_empty
    end
    
    it "should only return id codes (which isn't very OO, but there you have it)" do
      result = ExternalCode.telephone_location_type_ids[0].kind_of? Fixnum
      result.should be_true
    end

  end

  describe 'telephone location types' do
    
    it 'should return all telephone location types in sort order' do
      location_types = ExternalCode.telephone_location_types
      location_types.should_not be_empty
      location_types.first.code_description.should == 'Unknown'
    end
 
  end
end
