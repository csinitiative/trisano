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
  
end
