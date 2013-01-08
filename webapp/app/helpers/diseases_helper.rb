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

module DiseasesHelper

  def show_hide_disease_section_link
    link_to_function "[#{t 'show_hide_details'}]" do |page|
      page << "$(this).up().up().up().next().toggle()"
    end
  end

  def disease_check_boxes(object_name, checked_values=[])
    name = object_name + "[disease_ids][]"
    tags = Disease.all(:order => 'disease_name').map do |disease|
      id = name.gsub('[', '_').gsub(']', '') + disease.id.to_s
      returning "" do |result|
        result << tag('label', nil, true)
        result << check_box_tag(name, disease.id, checked_values.include?(disease.id), :id => id)
        result << tag('span', disease_label_options(disease), true)
        result << disease.disease_name
        result << "</span>"
        result << "</label>"
      end
    end
    tags.join
  end

  def disease_label_options(disease)
    returning({}) do |options|
      options[:class] = :inactive unless disease.active
    end
  end

  def disease_tool_links(disease)
    links = []
    links << link_to_unless_current(t(:edit), edit_disease_path(disease))
    links << link_to_unless_current(t(:show), disease)
    links << link_to_unless_current(t(:core_fields), disease_core_fields_path(disease))
    links << link_to_unless_current(t(:treatments), disease_treatments_path(disease))
    links
  end

  def render_disease_tool_links(disease)
    disease_tool_links(disease).join('&nbsp;|&nbsp;')
  end

  def apply_to_diseases_dialog(disease, action_path)
    result =  "<div class='apply_to_disease_dialog' style='display: none'>"
    result << image_tag('redbox_spinner.gif', :id => "diseaseListSpinner", :alt => 'Working...')
    result << "<label>#{link_to(t(:diseases), diseases_path)}</label>"
    result << form_tag(action_path, :id => 'apply_to_disease_form')
    result << "<table class='list' id='dialog_disease_list'></table>"
    result << '</form>'
    result << "</div>"
  end

  def disease_list_template(disease)
    <<-SCRIPT
      <script id="diseaseListTemplate" type="text/x-jquery-tmpl">
        {{if id != #{disease.id}}}
          <tr class="roll">
            <td><input type="checkbox" id="other_disease_${id}" name="other_disease_ids[]" value="${id}"/></td>
            <td>
              {{if active}}
                <label class="active" for="other_disease_${id}">${disease_name}</label>
              {{else}}
                <label class="inactive" for="other_disease_${id}">${disease_name}</label>
              {{/if}}
            </td>
          </tr>
        {{/if}}
      </script>
    SCRIPT
  end

  def apply_to_diseases_javascript_content
    content_for :javascript_includes do
      javascript_include_tag 'trisano/trisano_diseases'
    end
  end

  def apply_to_diseases_button_content
    content_for :tools_two do
      "<button class=\"apply_to_diseases\">#{t(:apply_to_diseases)}</button>"
    end
  end

  def render_apply_to_diseases(disease, apply_to_action)
    apply_to_diseases_javascript_content
    apply_to_diseases_button_content

    result = apply_to_diseases_dialog(disease, apply_to_action)
    result << disease_list_template(disease)
  end

end
