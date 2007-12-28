require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'
require 'rest-open-uri'
require 'rexml/document'

include REXML

class CmrsIntegrationTest < ActionController::IntegrationTest
  
  fixtures :cmrs
 
  def test_edit_cmr
    get "/cmrs"
    assert_response :success
    assert_template "cmrs/index"
    
    get "/cmrs/1/edit"
    assert_response :success
    assert_template "cmrs/edit"
    assert_select "form"
    
    put "/cmrs/1"
    assert_response :redirect
    follow_redirect!
    assert_template "cmrs/show"
  end
  

end