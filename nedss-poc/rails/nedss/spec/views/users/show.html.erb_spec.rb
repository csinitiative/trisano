require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/show.html.erb" do
  include UsersHelper
  
  before(:each) do
    @user = mock_model(User)

    assigns[:user] = @user
  end

  it "should render attributes in <p>" do
    render "/users/show.html.erb"
  end
end

