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

module FormsLibraryHelper
  
  def render_library(type, direction)
    type = type.to_s.camelcase
    result = ""
    result += render_library_no_group(type, direction)
    result += render_library_groups(type, direction)
  end
  
  private

  def render_library_no_group(type, direction)
    result = ""
    
    if (direction == :to_library)
      result += link_to_remote("No Group", 
        :update => "library-element-list-#{@reference_element.id}", 
        :complete => visual_effect(:highlight, "library-element-list-#{@reference_element.id}"), 
        :url => {
          :controller => "forms", 
          :action => "to_library", 
          :group_element_id => "root", 
          :reference_element_id => @reference_element.id
        }
      )
    end
    
    result += "<ul>"
    
    for form_element in @library_elements
      next if form_element.is_a? GroupElement
      
      if ((form_element.class.name == type) && (form_element.is_a?(QuestionElement)))  
        result += render_library_question(form_element, direction)
      elsif ((form_element.class.name == type) && (form_element.is_a?(ValueSetElement)))
        result += render_library_value_set(form_element, direction)
      end
      
    end
    
    result += "</ul>"
  end
  
  def render_library_groups(type, direction)
    
    result = ""
    result += "<ul>"

    grouped_count = 0
    
    for form_element in @library_elements
      next unless form_element.is_a? GroupElement
      
      result += "Grouped:" if grouped_count == 0
      
      result += "<li id='lib_group_item_#{form_element.id}', class='lib-question-item'>"
      
      if (direction == :to_library)
        result += link_to_remote("Add element to: #{form_element.name}", 
          :update => "library-element-list-#{@reference_element.id}", 
          :complete => visual_effect(:highlight, "library-element-list-#{@reference_element.id}"), 
          :url => {
            :controller => "forms", 
            :action => "to_library", 
            :group_element_id => form_element.id, 
            :reference_element_id => @reference_element.id
          }
        )
      else       
        if ((type == "QuestionElement") && (form_element.is_a?(GroupElement)))
          result += link_to_remote("Click to add all questions in group: #{form_element.name}", 
            :update => "#{@replace_element}", 
            :complete => visual_effect(:highlight, "#{@replace_element}"), 
            :url => {
              :controller => "forms", 
              :action => "from_library", 
              :reference_element_id => @reference_element.id, 
              :lib_element_id => form_element.id
            }
          )
        else
          result += "<b>#{form_element.name}</b>"
        end
      end
      
      
      result += "<ul>"
      
      for child_element in form_element.children
        if ((child_element.class.name == type) && (child_element.is_a?(QuestionElement)))
          result += render_library_question(child_element, direction)
        elsif ((child_element.class.name == type) && (child_element.is_a?(ValueSetElement)))
          result += render_library_value_set(child_element, direction)
        end
      end
      
      result += "</ul>"
      result += "<br/></li>"
      
      grouped_count += 1
    end
    
    result += "</ul>"
    result
  end
  
  def render_library_question(question_element, direction)
    result = ""
    
    result += "<li id='lib_question_item_#{question_element.id}', class='lib-question-item'>"
    
    if (direction == :to_library)
      result += question_element.question.question_text
    else
      result += link_to_remote(question_element.question.question_text, 
        :update => "#{@replace_element}", 
        :complete => visual_effect(:highlight, "#{@replace_element}"), 
        :url => {
          :controller => "forms", 
          :action => "from_library", 
          :reference_element_id => @reference_element.id, 
          :lib_element_id => question_element.id
        }
      )
    end
    
    result += "&nbsp;&nbsp;<small>" + question_element.question.data_type_before_type_cast.humanize + "</small>"
    question_element.pre_order_walk do |element|
      result += "<br />&nbsp;&nbsp;<em><small>Value Set:&nbsp;&nbsp;" + element.name + "</small></em>: " if element.is_a? ValueSetElement
      result += fml("<em><small>", element.name, "</small></em>&nbsp;&nbsp;") if element.is_a? ValueElement and !element.name.blank?
    end
          
    result += "</li>"
    
    result
  end
  
  def render_library_value_set(value_set_element, direction)
    result = ""
    
    result += "<li>"
    
    if (direction == :to_library)
      result += value_set_element.name
    else
      result += link_to_remote(value_set_element.name, 
        :update => "#{@replace_element}", 
        :complete => visual_effect(:highlight, "#{@replace_element}"), 
        :url => {
          :controller => "forms", 
          :action => "from_library", 
          :reference_element_id => @reference_element.id, 
          :lib_element_id => value_set_element.id
        }
      )
    end
    
    result += "<ul>"
    
    value_set_element.children.each do |element|
      if element.name.blank?
        "<li><em><small>(Blank)</small></em></li>"
      else
        result += fml("<li><em><small>", element.name, "</small></em></li>") 
      end
    end
    
    result += "</ul>"
    result += "</li>"
    
    result
  end
  
end
