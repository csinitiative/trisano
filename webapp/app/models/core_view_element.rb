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

class CoreViewElement < FormElement
  
  attr_accessor :parent_element_id
  
  validates_presence_of :name
  
  def available_core_views
    return nil if parent_element_id.blank?
    parent_element = FormElement.find(parent_element_id)
    form = Form.find(parent_element.form_id)
    names_in_use = []
    parent_element.children_by_type("CoreViewElement").each { |view| names_in_use << view.name }
    eval(form.event_type.camelcase).core_views.collect { |core_view| if (!names_in_use.include?(core_view[1]))
        core_view
      end
    }.compact
  end
  
end
