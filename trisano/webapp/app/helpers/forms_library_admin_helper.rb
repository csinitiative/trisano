# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

module FormsLibraryAdminHelper
  
  def render_library_admin(type)
    
    type_humanized = type.to_s.humanize.downcase.pluralize
    type= type.to_s.camelize
    
    result = ""
    
    result += "<h2>Ungrouped #{type_humanized}</h2>"
    
    result += "<ul>"
    
    for ungrouped_form_element in @library_elements
      next if ungrouped_form_element.is_a? GroupElement
      
      if ((ungrouped_form_element.class.name == type) && (ungrouped_form_element.is_a?(QuestionElement)))
        result += render_library_admin_question(ungrouped_form_element)
      elsif ((ungrouped_form_element.class.name == type) && (ungrouped_form_element.is_a?(ValueSetElement)))
        result += render_library_admin_value_set(ungrouped_form_element)
      end
    end
    
    result += "</ul>"
    
    result += "<h2>Grouped #{type_humanized}</h2>"
    
    for grouped_form_element in @library_elements
      next unless grouped_form_element.is_a? GroupElement
      
      result += "<h3 id='lib_group_admin_item_#{grouped_form_element.id}'>Group: #{grouped_form_element.name}</h3>"
      
      result += "<ul>"
      
      for child in grouped_form_element.children
        if ((child.class.name == type) && (child.is_a?(QuestionElement)))
          result += render_library_admin_question(child)
        elsif ((child.class.name == type) && (child.is_a?(ValueSetElement)))
          result += render_library_admin_value_set(child)
        end
      end
       
      result += "</ul>"
      
    end
    
    result
  end
  
  private
  
  def render_library_admin_question(element)
    result = "<li id='question_#{element.id}' class='lib-admin-question-item'>#{element.question.question_text}"
    result += "&nbsp;&nbsp;<small>#{element.question.data_type_before_type_cast.humanize}</small>"
    
    element.children do |child|
      result += "<br />&nbsp;&nbsp;<em><small>Value Set:&nbsp;&nbsp;#{child.name}</small></em>: " if child.is_a? ValueSetElement
      result += fml("<em><small>#{child.name}</small></em>&nbsp;&nbsp;") if child.is_a? ValueElement
    end
    
    result += "&nbsp;&nbsp;" + delete_question_link(element) + "</li>"
  end
  
  def render_library_admin_value_set(element)
    result = "<li id='value_set_#{element.id}' class='lib-admin-value-set-item'>#{element.name}"
    result += "<ul>"
    
    element.children.each do |child|
      result += fml("<li><em><small>", child.name, "</small></em></li>")
    end
    
    result += "</ul>"
    result += "</li>"
  end
  
end
