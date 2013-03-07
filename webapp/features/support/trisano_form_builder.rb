# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

def create_form(event_type, form_name, form_short_name, disease)
  form = Form.new
  form.event_type = event_type + "_event"
  form.name = form_name
  form.short_name = "#{form_short_name}_#{get_random_word}"
  form.diseases_forms.build(:disease_id => Disease.find_or_create_by_disease_name(:disease_name => disease, :active => true).id, :auto_assign => true)
  form.save_and_initialize_form_elements
  raise "Could not create form" if form.nil?
  form
end

def create_published_form(event_type, form_name, form_short_name, disease)
  form = create_form(event_type, form_name, form_short_name, disease)
  form.publish
end

def save_new_form(form_name)
  submit_form "new_form"
  response.should contain("Form was successfully created.")
  response.should contain(form_name)
end

def create_question_on_form(form, form_attributes, question_parent=nil)
  question_text = form_attributes[:question_text].blank? ? "#{get_unique_name(3)} question" : form_attributes[:question_text]
  data_type = form_attributes[:data_type].blank? ? "single_line_text" : form_attributes[:data_type]
  short_name = form_attributes[:short_name].blank? ? get_unique_name(2) : form_attributes[:short_name]
  question_parent = question_parent.nil? ? form.investigator_view_elements_container.children[0] : question_parent

  question_element = QuestionElement.new({
      :parent_element_id => question_parent.id,
      :question_attributes => {
        :question_text =>  question_text,
        :data_type => data_type,
        :short_name => short_name
      }
    }
  )

  question_element.save_and_add_to_form
  question_element
end

def add_value_set_to_question(question_element, value_set_name, values)
  value_set_element = ValueSetElement.new({
      :parent_element_id => question_element.id,
      :name => value_set_name
    }
  )
  value_set_element.save_and_add_to_form
  
  values.each do |value_array|
    value_set_element.add_child ValueElement.create!(:name => value_array[0], :code => value_array[1], :tree_id => value_set_element.tree_id)
    value_set_element.save!
  end
end


def create_value_elements_in_value_set(value_set_element, values_table)
  values_table.rows.each do |row|
    value_set_element.add_child ValueElement.create!(:name => row.first, :code => row.last, :tree_id => value_set_element.tree_id)
  end
  value_set_element.save!
end
