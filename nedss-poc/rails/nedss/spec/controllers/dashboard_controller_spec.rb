require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController do

  describe "handling GET /dashboard" do
    
    before(:each) do
      mock_user
    end
    
    def do_get
      get :index
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render index template" do
      do_get
      response.should render_template('index')
    end
    
    it "should assign a user" do
      do_get
      User.current_user.nil?.should be_false
    end
    
  end
 
 # How to test this when we can't undo the user id already in the environment?
#  describe "handling GET /dashboard with no logged in user" do
#    
#    it "should redirect to 500 error page" do
#      get :index
#      response.should redirect_to("/500.html")
#    end
#    
#  end
  
end