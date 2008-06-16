require File.dirname(__FILE__) + '/spec_helper'

$dont_kill_browser = true

describe 'Form Builder Admin Core Follow-Up Functionality' do
  
  before(:all) do
    @form_name = NedssHelper.get_unique_name(2) + " follow up uat"

  end
  
  after(:all) do
    @form_name = nil

  end
  
  it 'should handle core follow-ups.' do

  end
    
end