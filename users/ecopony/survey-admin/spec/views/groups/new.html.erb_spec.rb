require File.dirname(__FILE__) + '/../../spec_helper'

describe "/groups/new.html.erb" do
  include GroupsHelper
  
  before(:each) do
    @group = mock_model(Group)
    @group.stub!(:new_record?).and_return(true)
    @group.stub!(:name).and_return("MyString")
    @group.stub!(:description).and_return("MyString")
    assigns[:group] = @group
  end

  it "should render new form" do
    render "/groups/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", groups_path) do
      with_tag("input#group_name[name=?]", "group[name]")
      with_tag("input#group_description[name=?]", "group[description]")
    end
  end
end


