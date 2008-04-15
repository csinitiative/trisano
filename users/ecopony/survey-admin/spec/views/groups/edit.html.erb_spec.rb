require File.dirname(__FILE__) + '/../../spec_helper'

describe "/groups/edit.html.erb" do
  include GroupsHelper
  
  before do
    @group = mock_model(Group)
    @group.stub!(:name).and_return("MyString")
    @group.stub!(:description).and_return("MyString")
    assigns[:group] = @group
  end

  it "should render edit form" do
    render "/groups/edit.html.haml"
    
    response.should have_tag("form[action=#{group_path(@group)}][method=post]") do
      with_tag('input#group_name[name=?]', "group[name]")
      with_tag('input#group_description[name=?]', "group[description]")
    end
  end
end


