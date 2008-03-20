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
      assigns[:user].should == @user
    end
    
  end
  
  describe "handling GET /dashboard with no logged in user" do
    
    before(:each) do
      User.stub!(:find_by_uid).and_return(nil)
    end
    
    it "should redirect to 500 error page" do
      get :index
      response.should redirect_to("/500.html")
    end
    
  end
  
end
