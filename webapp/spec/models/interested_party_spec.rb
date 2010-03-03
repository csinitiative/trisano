require File.dirname(__FILE__) + '/../spec_helper'

describe InterestedParty do
  it "should have a person" do
    ip = InterestedParty.new
    ip.build_person_entity
    ip.save
    ip.errors.on(:base).should == "No information has been supplied for the interested party."
  end
end
