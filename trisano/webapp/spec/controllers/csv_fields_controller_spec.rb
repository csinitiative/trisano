require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CsvFieldsController do

  #Delete these examples and add some real ones
  it "should use CsvFieldsController" do
    controller.should be_an_instance_of(CsvFieldsController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      get 'update'
      response.should be_success
    end
  end
end
