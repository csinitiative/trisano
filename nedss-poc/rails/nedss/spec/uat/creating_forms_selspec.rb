require File.dirname(__FILE__) + '/spec_helper'

describe "Form creation page" do

  it 'should allow a user to create a basic form' do
    @browser.open "/nedss/cmrs"
    @browser.click 'link=Forms'
    @browser.wait_for_page_to_load '30000'
    @browser.click 'link=New form'
    @browser.wait_for_page_to_load '30000'
    @browser.type 'form_name', 'A Test Form'
    @browser.type 'form_description', 'This Form Is Not A Real Form At All, Just a Simple Test Form. I think this field ought to be larger.'
    @browser.select 'form_disease_id', 'label=AIDS'
    @browser.select 'form_jurisdiction_id', 'label=Bear River Health Department'
    @browser.click 'form_submit'
    @browser.wait_for_page_to_load '30000'

    #verify everything was saved
    @browser.is_text_present('Form was successfully created.').should be_true
    @browser.is_text_present('Form details: A Test Form').should be_true
    @browser.is_text_present('Name: A Test Form').should be_true
    @browser.is_text_present('Description: This Form Is Not A Real Form At All, Just a Simple Test Form. I think this field ought to be larger.').should be_true
    @browser.is_text_present('Show for disease: AIDS').should be_true
    @browser.is_text_present('Show for jursidiction: Bear River Health Department').should be_true
    @browser.is_text_present('Edit').should be_true
    @browser.is_text_present('Back').should be_true
    @browser.is_text_present('Form Builder').should be_true
  
    #verify the form made it into the list using the back link
    @browser.click 'link=Back'
    @browser.wait_for_page_to_load '30000'
    @browser.is_text_present('Listing forms').should be_true
    @browser.is_text_present('A Test Form').should be_true
    @browser.is_text_present('This Form Is Not A Real Form At All, Just a Simple Test Form. I think this field ought to be larger.').should be_true
  
    #delete the form
    #@browser.click 'link=Destroy'
    pending do
      @browser.is_text_present('Form was successfully destroyed.').should be_true #not yet implemented...
    end
  end
  
  it "should be able to create a form from just questions" 
  it "should be able to create a form from just sections" 
  it "should be able to create a form from from a mix of sections and questions" 

end
