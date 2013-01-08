# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/spec_helper' 

describe "Form builder admin" do 
  before(:all) do
    @s_name = get_unique_name(4)
    @s2_name = get_unique_name(4)
    @q_name = get_unique_name(25)
    @q2_name = get_unique_name(15)
    @q_edit_name = get_unique_name(35)
  end
  before(:each) do
    #put any setup tasks here
  end
  
  #$dont_kill_browser = true
  
  it "should allow admin to create a form" do 
    @browser.open "/trisano/"
    
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load($load_time)
    
    @browser.click "link=New form"
    @browser.wait_for_page_to_load($load_time)
    f_name = get_unique_name(4)
    @browser.type "form_name", f_name
    @browser.click "form_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("Form was successfully created.").should be true    
  end
  
  it "should allow admin to edit the form" do
    @browser.click "link=Form Builder"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present(" Form Hierarchy").should be true
  end
  
  it "should allow admin to add a section to the form" do
    @browser.click "link=Add a section"
    wait_for_element_present("new-section-form")
    
    @browser.type("section_element_name", @s_name)
    @browser.click "section_element_submit"
    wait_for_element_not_present("new-section-form")
    @browser.is_text_present("Section configuration was successfully created.").should be true 
  end
  
  it "should allow admin to add another section to the form" do
    @browser.click "link=Add a section"
    wait_for_element_present("new-section-form")
    
    @browser.type("section_element_name", @s2_name)
    @browser.click "section_element_submit"
    wait_for_element_not_present("new-section-form")
    @browser.is_text_present("Section configuration was successfully created.").should be true 
  end
  
  it "should allow admin to add a question to the second section" do
    add_question_to_view(@browser, @s2_name, @q_name, "Phone Number")
    @browser.is_text_present("Question was successfully created.").should be true
  end
  
  it "should allow admin to add another question to the second section" do
    add_question_to_view(@browser, @s2_name, @q_name, "Phone Number")
    @browser.is_text_present("Question was successfully created.").should be true
  end
  
  it "should allow admin to edit the first question" do
    click_question(@browser, @q_name, "edit")
    @browser.type "question_element_question_attributes_question_text", @q_edit_name
    @browser.click "question_element_submit"
    sleep 2
    #wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Question was successfully updated.").should be true
    @browser.is_text_present(@q_edit_name).should be true
    @browser.is_text_present(@q_name).should be false
  end
  
  it "should allow admin to delete the second question from the section" do
    click_question(@browser, @q2_name, "delete")
    @browser.is_text_present("The form element was successfully deleted.").should be true
    @browser.is_text_present(@q2_name).should be false
  end
  
  it "should allow admin to copy questions to the form library"  
    
end
