require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/edit.html.haml" do
  include UsersHelper
  
  before do
    @user = mock_user
    assigns[:user] = @user
  end

  it "should render edit form" do
    render "/users/edit.html.haml"
    
    response.should have_tag("form[action=#{user_path(@user)}][method=post]") do
    end
  end
end


