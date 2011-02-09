require 'spec_helper'

describe ExternalCodesController do
  fixtures :code_names

  before do
    mock_user
  end

  it "returns external codes codes by code name" do
    lambda { get 'index_code', :code_name => 'race' }.should_not raise_error
    response.should be_success
    assigns[:external_codes].should_not be_nil
  end

  it "returns external codes as xml" do
    lambda do
      request.env['HTTP_ACCEPT'] = 'application/xml'
      get 'index_code', :code_name => 'race'
    end.should_not raise_error
    response.should be_success
    response.content_type.should == 'application/xml'
  end
end
