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

class ValueSetElement < FormElement

  has_many :value_elements,
    :class_name => "FormElement",
    :foreign_key => :parent_id,
    :dependent => :destroy

  validates_presence_of :name

  # mask has_one, since we don't want any db side effects
  attr_accessor :question

  def save_and_add_to_form
    begin
      parent_element = FormElement.find(parent_element_id)
      unless parent_element.can_receive_value_set?
        self.errors.add_to_base(:too_many_value_sets)
        return nil
      end
    rescue Exception => ex
      self.errors.add_to_base(:bad_parent)
      return nil
    end

    super
  end

  def copy_children(options={})
    children.each do |child|
      child.question = self.question.try :clone
      child.copy_with_children(options)
    end
  end
end
