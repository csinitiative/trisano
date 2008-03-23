require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/index.html.haml" do
  include UsersHelper
  
  before(:each) do
    user_98 = mock_user
    user_99 = mock_user

    assigns[:users] = [user_98, user_99]
  end

  it "should render list of users" do
    render "/users/index.html.haml"
  end
end

