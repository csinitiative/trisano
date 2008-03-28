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
    
    def do_get
      get :index
    end
    
    it "should be be a 403" do
      do_get
      response.response_code.should == 403
    end
    
  end
  
end
