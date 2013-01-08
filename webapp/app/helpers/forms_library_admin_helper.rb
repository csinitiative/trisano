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

module FormsLibraryAdminHelper

  def render_library_admin(type)
    type = type.to_s.camelize

    for ungrouped_form_element in @library_elements
      next if ungrouped_form_element.is_a? GroupElement

      if ungrouped_form_element.class.name == type
        if ungrouped_form_element.is_a? QuestionElement
          render_library_admin_question ungrouped_form_element, type
        elsif ungrouped_form_element.is_a? ValueSetElement
          render_library_admin_value_set ungrouped_form_element, type
        end
      end
    end

    for grouped_form_element in @library_elements
      next unless grouped_form_element.is_a? GroupElement

      haml_tag :li, {:id => "lib_group_admin_item_#{grouped_form_element.id}"} do
        haml_tag :p do
          haml_tag :b do
            haml_concat "Group: #{grouped_form_element.name}"
          end
          haml_concat "&nbsp;&nbsp;"
          haml_concat link_to_library_admin_delete(grouped_form_element, type)
        end
      end

      for child in grouped_form_element.children
        if child.class.name == type
          if child.is_a? QuestionElement
            render_library_admin_question child, type
          elsif child.is_a? ValueSetElement
            render_library_admin_value_set child, type
          end
        end
      end
    end

    nil
  end

  private

  def render_library_admin_question(element, type)
    haml_tag :li, {:id => "question_#{element.id}", :class => 'library-admin-item'} do
      haml_concat element.question.question_text
      haml_concat "&nbsp;"
      haml_concat element.question.short_name
      haml_concat "&nbsp;&nbsp;"
      haml_concat I18n.t("question_data_types.#{element.question.data_type_before_type_cast}")

      element.children do |child|
        haml_concat "&nbsp;&nbsp;Value Set:&nbsp;&nbsp;#{child.name}: " if child.is_a? ValueSetElement
        haml_concat fml("#{child.name}&nbsp;&nbsp;") if child.is_a? ValueElement and !child.name.blank?
      end

      haml_concat "&nbsp;&nbsp;"
      haml_concat link_to_library_admin_delete(element, type)
    end
  end

  def render_library_admin_value_set(element, type)
    haml_tag :li, {:id => "value_set_#{element.id}", :class => 'library-admin-item'} do
      haml_tag :b do
        haml_concat element.name
        haml_concat "&nbsp;&nbsp;"
        haml_concat link_to_library_admin_delete(element, type)
      end
      haml_tag :br

      element.children.each_with_index do |child, i|
        haml_concat " | " unless i == 0
        if child.name.blank?
          haml_concat "(Blank)"
        else
          haml_concat fml("", child.name, "")
        end
      end
    end
  end

  def link_to_library_admin_delete(element, type)
    html_class_name = "delete-" + element.class.name.underscore.gsub(/_element$/, '').gsub('_', '-')
    link_to_remote(image_tag('delete.png', :border => 0, :alt => html_class_name.titleize),
                   :url     => form_element_path(element, :type => type.underscore),
                   :method  => :delete,
                   :confirm => 'This action will delete this element and all children elements. Please confirm.',
                   :html    => {:class => html_class_name, :id => "#{html_class_name}-#{element.id}"})
  end
end
