require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CoreFieldsDisease do
  it { should belong_to(:disease) }
  it { should belong_to(:core_field) }

  it "requires a disease" do
    cfd = CoreFieldsDisease.create
    cfd.errors.on(:disease).should == "can't be blank"
  end

  it "requires a core field" do
    cfd = CoreFieldsDisease.create
    cfd.errors.on(:core_field).should == "can't be blank"
  end

end
