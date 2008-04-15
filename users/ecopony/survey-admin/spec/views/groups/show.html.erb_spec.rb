require File.dirname(__FILE__) + '/../../spec_helper'

describe "/groups/show.html.erb" do
  include GroupsHelper
  
  before(:each) do
    @group = mock_model(Group)
    @group.stub!(:name).and_return("MyString")
    @group.stub!(:description).and_return("MyString")

    assigns[:group] = @group
  end

  it "should render attributes in <p>" do
    render "/groups/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

