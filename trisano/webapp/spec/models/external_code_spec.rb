require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalCode do
  before(:each) do
    @external_code = ExternalCode.new
  end

  it "should be valid" do
    @external_code.should be_valid
  end

  describe 'telephone location types' do
    
    it 'should be able to provide a list of telephone location type ids' do
      ExternalCode.telephone_location_type_ids.should_not be_empty
    end
    
    it "should only return id codes (which isn't very OO, but there you have it)" do
      result = ExternalCode.telephone_location_type_ids[0].kind_of? Fixnum
      result.should be_true
    end

  end
end
