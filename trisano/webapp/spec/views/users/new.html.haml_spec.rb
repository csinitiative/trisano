require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/new.html.haml" do
  include UsersHelper
  
  before(:each) do
    @user = mock_user
    @user.stub!(:new_record?).and_return(true)
    assigns[:user] = @user
  end

  it "should render new form" do
    render "/users/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", users_path) do
    end
  end
end


