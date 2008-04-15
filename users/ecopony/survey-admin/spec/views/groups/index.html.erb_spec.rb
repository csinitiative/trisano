require File.dirname(__FILE__) + '/../../spec_helper'

describe "/groups/index.html.erb" do
  include GroupsHelper
  
  before(:each) do
    group_98 = mock_model(Group)
    group_98.should_receive(:name).and_return("MyString")
    # group_98.should_receive(:description).and_return("MyString")
    group_99 = mock_model(Group)
    group_99.should_receive(:name).and_return("MyString")
    # group_99.should_receive(:description).and_return("MyString")

    assigns[:groups] = [group_98, group_99]
  end

  it "should render list of groups" do
    render "/groups/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
    # response.should have_tag("tr>td", "MyString", 2)
  end
end

