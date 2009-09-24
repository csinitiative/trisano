require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AvrGroup do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    AvrGroup.create!(@valid_attributes)
  end

  it "should not be valid without a name" do
    AvrGroup.create(:name => '').errors.on(:name).should == "can't be blank"
  end

  it 'should have a unique name' do
    AvrGroup.create(:name => 'Lurgies')
    AvrGroup.create(:name => 'Lurgies').errors.on(:name).should == "has already been taken"
  end


end
