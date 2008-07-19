require File.dirname(__FILE__) + '/../spec_helper'

describe Telephone do
  before(:each) do
    @phone = Telephone.new
  end

  it "should be valid without a properly formatted phone_number" do
    @phone.should_not be_valid
  end

  it "should produce a simple phone format" do
    phone = Telephone.new(:area_code => '123', 
                          :phone_number => '765-4321',
                          :extension => '9')
    phone.simple_format.should == '(123) 765-4321 Ext. 9'
  end
  
  it "should produce a phone format w/out an area code" do
    phone = Telephone.new(:phone_number => '765-4321',
                          :extension   => '9')
    phone.simple_format.should == '765-4321 Ext. 9'
  end

  it "should produce a phone format w/out an extension" do
    phone = Telephone.new(:area_code => '123',
                          :phone_number => '765-4321')
    phone.simple_format.should == '(123) 765-4321'
  end

  # TODO: test validations here

end
