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

module FormsLibraryAdminHelper
  
  def render_library_admin(type)
    
    type_humanized = type.to_s.humanize.downcase.pluralize
    type= type.to_s.camelize
    
    result = ""
    
#    result += "<ul>"
    
    for ungrouped_form_element in @library_elements
      next if ungrouped_form_element.is_a? GroupElement
      
      if ((ungrouped_form_element.class.name == type) && (ungrouped_form_element.is_a?(QuestionElement)))
        result += render_library_admin_question(ungrouped_form_element, type)
      elsif ((ungrouped_form_element.class.name == type) && (ungrouped_form_element.is_a?(ValueSetElement)))
        result += render_library_admin_value_set(ungrouped_form_element, type)
      end
    end
    
#    result += "</ul>"
    
    for grouped_form_element in @library_elements
      next unless grouped_form_element.is_a? GroupElement
      
#      result += "<ul><li>"
      result += "<p><b><id='lib_group_admin_item_#{grouped_form_element.id}'>Group: #{grouped_form_element.name}</b>"
      
      for child in grouped_form_element.children
        if ((child.class.name == type) && (child.is_a?(QuestionElement)))
          result += render_library_admin_question(child, type)
        elsif ((child.class.name == type) && (child.is_a?(ValueSetElement)))
          result += render_library_admin_value_set(child, type)
        end
      end
       
#      result += "</li></ul>"
      
    end
    
    result
  end
  
  private
  
  def render_library_admin_question(element, type)
    result = "<li id='question_#{element.id}' class='library-admin-item'>#{element.question.question_text}"
    result += "&nbsp;&nbsp;#{element.question.data_type_before_type_cast.humanize}"
    
    element.children do |child|
      result += "&nbsp;&nbsp;Value Set:&nbsp;&nbsp;#{child.name}: " if child.is_a? ValueSetElement
      result += fml("#{child.name}&nbsp;&nbsp;") if child.is_a? ValueElement and !child.name.blank?
    end
    
    result += "&nbsp;&nbsp;<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/" + 
      element.id.to_s + "?type=#{type.underscore}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-question' id='delete-question-" + 
      element.id.to_s + "'>" + image_tag("delete.png", :border => 0, :alt => "Delete Question") + "</a></li>"
  end
  
  def render_library_admin_value_set(element, type)
    result = "<li id='value_set_#{element.id}' class='library-admin-item'><b>#{element.name}</b><br>"
#    result += "<ul>"
    
    element.children.each do |child|
       if child.name.blank?
         result += "(Blank)"
      else
        result += fml("", child.name, "") 
      end
    end
    
#    result += "</ul>"
    result += "</li>"
  end
  
end
