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
module QuestionElementSpecHelper

  def with_question_element
    form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
    form.short_name = "short_name_editable_#{rand(20000)}"
    form.save_and_initialize_form_elements
    section_element = SectionElement.new(:name => "Test")
    section_element.parent_element_id = form.investigator_view_elements_container.children[0]
    section_element.save_and_add_to_form.should_not be_nil
    question_element = QuestionElement.new({
        :parent_element_id => section_element.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
      })
    yield question_element if block_given?
  end

end
