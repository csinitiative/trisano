# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  
  it "should determine replacement elements for a library admin action" do
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :question => question)
    
    replace_element, replace_partial = helper.replacement_elements(question_element)
        
    replace_element.should eql("library-admin")
    replace_partial.should eql("forms/library_admin")
  end
  
  it "should determine replacement elements for a investigator view child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    investigator_view_element_container = InvestigatorViewElementContainer.create(:tree_id => "1")
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :form_id => 1, :question => question)
    
    form_base_element.add_child(investigator_view_element_container)
    investigator_view_element_container.add_child(question_element)
    
    replace_element, replace_partial = helper.replacement_elements(question_element)
    
    replace_element.should eql("root-element-list")
    replace_partial.should eql("forms/elements")
  end
  
  it "should determine replacement elements for a core view child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    core_view_element_container = CoreViewElementContainer.create(:tree_id => "1")
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :form_id => 1, :question => question)
    
    form_base_element.add_child(core_view_element_container)
    core_view_element_container.add_child(question_element)
    
    replace_element, replace_partial = helper.replacement_elements(question_element)
    
    replace_element.should eql("core-element-list")
    replace_partial.should eql("forms/core_elements")
  end
  
  it "should determine replacement elements for a core field child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    core_field_element_container = CoreFieldElementContainer.create(:tree_id => "1")
     question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :form_id => 1, :question => question)
    
    form_base_element.add_child(core_field_element_container)
    core_field_element_container.add_child(question_element)
    
    replace_element, replace_partial = helper.replacement_elements(question_element)
    
    replace_element.should eql("core-field-element-list")
    replace_partial.should eql("forms/core_field_elements")
  end

  it "should format date correctly" do
    helper.format_date(Time.parse('8/21/2002')).should eql('August 21, 2002')
  end
  
end
