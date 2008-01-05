require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'
require 'mechanize'
require 'rexml/document'
require 'rest-open-uri'

include REXML

class CmrsExternalIntegrationTest < Test::Unit::TestCase
  
  def test_get_cmrs
    
    agent = WWW::Mechanize.new
    page = agent.get 'http://localhost:3000/cmrs'
    
    # result = open("http://localhost:3000/cmrs")
    # assert_equal("200", result.status[0])
    # page = Hpricot(result.read)
    
    assert_not_nil(page.search("//a[@href='/cmrs/new']")[0], "There should be at least one new CMR link")
    assert_not_nil(page.search("//a:contains('Show')")[0], "There should be at least one Show link")
    assert_not_nil(page.search("//a:contains('Edit')")[0], "There should be at least one Edit link")
    assert_not_nil(page.search("//a:contains('Destroy')")[0], "There should be at least one Destroy link")
    
    link = page.links.text(/New cmr/)
    page = agent.click(link)
    
    # Inspect the form?
    
    form = page.forms[0]
    form['cmr[first_name]'] = 'Chuck'
    form['cmr[last_name]'] = 'Paley'
    form['cmr[date_of_birth]'] = 'november, 12, 1977'
    page = agent.submit(form, form.buttons.first)
    
    # Inspect the Show page?
    
  end
 
  
  
  
  

end
