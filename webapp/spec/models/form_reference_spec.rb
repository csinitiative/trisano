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

require File.dirname(__FILE__) + '/../spec_helper'

describe FormReference do
  it "deletes form answers when destroyed" do
    event = Factory(:morbidity_event)
    form1 = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'form_element_short_1')
    form1.save_and_initialize_form_elements
    form1.update_attribute :template_id, form1.id
    question_element1 = QuestionElement.new({
        :parent_element_id => form1.investigator_view_elements_container.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
      })

    question_element1.save_and_add_to_form.should_not be_nil
    question1 = question_element1.question

    form2 = Form.new(:name => "Test Form 2", :event_type => 'morbidity_event', :short_name => 'form_element_short_2')
    form2.save_and_initialize_form_elements
    form2.update_attribute :template_id, form2.id
    question_element2 = QuestionElement.new({
        :parent_element_id => form2.investigator_view_elements_container.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy_2"}
      })

    question_element2.save_and_add_to_form.should_not be_nil
    question2 = question_element2.question
    FormReference.all.count.should == 0
    event.add_forms([form1.id, form2.id])
    FormReference.all.count.should == 2

    event.answers.count.should == 0
    event.answers.create!(:question => question1)
    event.answers.create!(:question => question2)
    event.answers.count.should == 2 
    event.remove_forms([form1.id])
    event.answers.reload.count.should == 1
    event.remove_forms([form2.id])
    event.answers.reload.count.should == 0
  end
end
