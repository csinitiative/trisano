require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/show.html.haml" do
  include UsersHelper
  
  before(:each) do
    @user = mock_user

    assigns[:user] = @user
  end

  it "should render attributes in <p>" do
    render "/users/show.html.haml"
  end
end

