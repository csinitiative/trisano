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

module FormsLibraryHelper

  def render_library(type, direction)
    type = type.to_s.camelcase
    library_element_cache = LibraryElementCache.new(@library_elements)

    result = ""
    result << render_library_no_group(library_element_cache, type, direction)
    result << render_library_groups(library_element_cache, type, direction)
    result
  end

  private

  def render_library_no_group(library_element_cache, type, direction)
    result = ""

    if (direction == :to_library)
      result << link_to_remote(t("no_group"),
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

    result << "<ul>"

    for form_element in library_element_cache
      next if form_element.is_a? GroupElement

      if ((form_element.class.name == type) && (form_element.is_a?(QuestionElement)))
        result << render_library_question(library_element_cache, form_element, direction)
      elsif ((form_element.class.name == type) && (form_element.is_a?(ValueSetElement)))
        result << render_library_value_set(library_element_cache, form_element, direction)
      end

    end

    result << "</ul>"
  end

  def render_library_groups(library_element_cache, type, direction)

    result = ""
    result << "<ul>"

    grouped_count = 0

    for group_element in library_element_cache
      next unless group_element.is_a? GroupElement

      result << "Grouped:" if grouped_count == 0

      result << "<li id='lib_group_item_#{group_element.id}' class='lib-question-item'>"

      if (direction == :to_library)
        result << link_to_remote("Add element to: #{group_element.name}",
          :update => "library-element-list-#{@reference_element.id}",
          :complete => visual_effect(:highlight, "library-element-list-#{@reference_element.id}"),
          :url => {
            :controller => "forms",
            :action => "to_library",
            :group_element_id => group_element.id,
            :reference_element_id => @reference_element.id
          }
        )
      else
        if ((type == "QuestionElement") && (group_element.is_a?(GroupElement)))
          result << link_to_remote("Click to add all questions in group: #{group_element.name}",
            :url => {
              :controller => "forms",
              :action => "from_library",
              :reference_element_id => @reference_element.id,
              :lib_element_id => group_element.id
            }
          )
        else
          result << "<b>#{group_element.name}</b>"
        end
      end

      if (direction == :from_library)
        group_element_cache = FormElementCache.new(group_element)

        result << "<ul>"

        for child_element in group_element_cache.children
          if ((child_element.class.name == type) && (child_element.is_a?(QuestionElement)))
            result << render_library_question(group_element_cache, child_element, direction)
          elsif ((child_element.class.name == type) && (child_element.is_a?(ValueSetElement)))
            result << render_library_value_set(group_element_cache, child_element, direction)
          end
        end

        result << "</ul>"

      end

      result << "<br/></li>"

      grouped_count += 1
    end

    result << "</ul>"
    result
  end

  def render_library_question(element_cache, question_element, direction)
    result = ""

    result << "<li id='lib_question_item_#{question_element.id}' class='lib-question-item'>"

    if (direction == :to_library)
      result << element_cache.question(question_element).question_text
    else
      result << link_to_remote(element_cache.question(question_element).question_text,
        :url => {
          :controller => "forms",
          :action => "from_library",
          :reference_element_id => @reference_element.id,
          :lib_element_id => question_element.id
        }
      )
    end

    result << "&nbsp;&nbsp;<small>#{I18n.t("question_data_types.#{question_element.question.data_type_before_type_cast}")}</small>"

    question_children = element_cache.children(question_element)

    question_children.each do |question_child|
      next unless question_child.is_a? ValueSetElement

      result << "<ul>"

      element_cache.children(question_child).each do |element|
        if element.name.blank?
          "<li><em><small>(Blank)</small></em></li>"
        else
          result << fml("<li><em><small>", element.name, "</small></em></li>")
        end
      end

      result << "</ul>"
    end

    result << "</li>"

    result
  end

  def render_library_value_set(element_cache, value_set_element, direction)
    result = ""

    result << "<li>"

    if (direction == :to_library)
      result << value_set_element.name
    else
      result << link_to_remote(value_set_element.name,
        :url => {
          :controller => "forms",
          :action => "from_library",
          :reference_element_id => @reference_element.id,
          :lib_element_id => value_set_element.id
        }
      )
    end

    result << "<ul>"

    element_cache.children(value_set_element).each do |element|
      if element.name.blank?
        "<li><em><small>(Blank)</small></em></li>"
      else
        result << fml("<li><em><small>", element.name, "</small></em></li>")
      end
    end

    result << "</ul>"
    result << "</li>"

    result
  end

end
