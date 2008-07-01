require File.dirname(__FILE__) + '/../../spec_helper'

describe "/layout/application.html.haml for an admin user" do
  before(:each) do
    @user = mock_user
     assigns[:user] = @user
  end

  def do_render
    render "/layouts/application.html.haml"
  end
  
  it "should render an template of the layout" do
    do_render
  end

  it "should render a user name" do
    do_render
    response.should have_text(/Johnny Johnson/)
  end
  
  it "should render the admin link" do
    do_render
    response.should have_text(/ADMIN/)
  end
  
end

describe "/layout/application.html.haml for a non-admin user" do
  before(:each) do
    @user = mock_user
    @user.stub!(:user_name).and_return("non_admin_user")
    @user.stub!(:is_admin?).and_return(false)
     assigns[:user] = @user
  end

  def do_render
    render "/layouts/application.html.haml"
  end
  
  it "should render the admin section of the left nav" do
    do_render
    response.should_not have_text(/Admin Home/)
  end
  
end
