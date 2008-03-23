require File.dirname(__FILE__) + '/../spec_helper'

describe AdminController do

  describe "handling GET /admin" do
    
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
    
  end
  
  describe "handling GET /admin without an admin user on the request" do
    
    before(:each) do
      mock_user
      @user.stub!(:is_admin?).and_return(false)
      @user.stub!(:user_name).and_return("not_an_admin")
    end
    
    it "should redirect to 403 error page" do
      get :index
      response.should redirect_to("/403.html")
    end
    
  end
  
end
