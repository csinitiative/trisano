require File.dirname(__FILE__) + '/../../spec_helper'

describe "/layout/application.html.erb" do
  before(:each) do
    @user = mock_model(User)
    @user.stub!(:user_name).and_return("default_user")
     assigns[:user] = @user
  end

  it "should render an template of the layout" do
    render "/layouts/application.html.erb"
  end

  it "should render a user name" do
    render "/layouts/application.html.erb"
    response.should have_text(/default_user/)
  end
  
end
