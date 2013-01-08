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

class CoreFieldElement < FormElement
  include I18nCoreField

  validates_presence_of :core_path

  def save_and_add_to_form
    if self.core_path.blank?
      errors.add_to_base(:blank_core_path)
      return nil
    end

    parent_element = FormElement.find(parent_element_id)
    super do
      before_core_field_element = BeforeCoreFieldElement.create(:tree_id => self.tree_id, :form_id => self.form_id)
      after_core_field_element = AfterCoreFieldElement.create(:tree_id => self.tree_id, :form_id => self.form_id)
      self.add_child(before_core_field_element)
      self.add_child(after_core_field_element)
    end
  end

  # debt: returns an array of unused core field, but also formats for select options.
  def available_core_fields
    return nil if parent_element_id.blank?
    parent_element = FormElement.find(parent_element_id)
    form = Form.find(parent_element.form_id)
    fields_in_use = []
    parent_element.children_by_type("CoreFieldElement").each { |field| fields_in_use << field.name }

    CoreField.event_fields(form.event_type).values.reject do |cf|
      fields_in_use.include?(cf.name) || !cf.fb_accessible
    end.map{|cf| [cf.name, cf.key]}.sort_by(&:first)
  end

  def core_field
     CoreField.find_by_key(core_path)
  end

end
