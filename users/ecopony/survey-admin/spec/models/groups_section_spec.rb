require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsSection do
  before(:each) do
    @groups_section = GroupsSection.new
  end

  it "should be valid" do
    @groups_section.should be_valid
  end
end
