require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ostruct'

describe CsvFieldsController do

  before(:each) do
    @current_user = mock_user
    User.stubs(:find).returns(@current_user)
  end

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

  describe "POST 'set_csv_field_short_name'" do
    it "should be successful" do
      @csv_field = Factory.build(:csv_field)
      @csv_field.expects(:short_name=).with('a_value')
      @csv_field.expects(:save).returns(true)
      @csv_field.expects(:short_name).returns('a_value')
      CsvField.expects(:find).with('1').returns(@csv_field)
      post :set_csv_field_short_name, :id => 1, :value => 'a_value'
      response.should be_success
    end

    it "should fail if save fails" do
      @csv_field = Factory.build(:csv_field)
      @csv_field.expects(:short_name=).with('a_value_too_long')
      @csv_field.expects(:save).returns(false)
      @csv_field.expects(:errors).returns(OpenStruct.new(:full_messages => ['Short name is too long']))
      CsvField.expects(:find).with('1').returns(@csv_field)
      post :set_csv_field_short_name, :id => 1, :value => 'a_value_too_long'
      response.should_not be_success
    end
  end

end
