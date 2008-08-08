require File.dirname(__FILE__) + '/../spec_helper'

describe Code do
  before(:each) do
    @code = Code.new
  end

  it "should be valid" do
    @code.should be_valid
  end

  describe 'Interested Party' do
    fixtures :codes

    it 'should exist' do 
      Code.interested_party.should_not be_nil
    end

  end
end
