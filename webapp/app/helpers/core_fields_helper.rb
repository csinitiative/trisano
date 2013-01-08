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

module CoreFieldsHelper
  extensible_helper

  def render_core_fields_list(roots)
    result = ""
    roots.each_as_cursor do |cursor|
      result << render(:partial => 'list_fields', :locals => { :root_cursor => cursor })
    end
    result
  end

  def link_back_to_core_fields(disease=nil)
    if disease
      link_to t(:back_to_disease_core_fields, :name => disease.disease_name), disease_core_fields_path
    else
      link_to t(:back_to_core_fields), core_fields_path
    end
  end

  def link_to_edit_core_field(core_field, disease=nil)
    if disease
      url = edit_disease_core_field_path(disease, core_field)
    else
      url = edit_core_field_path(core_field)
    end
    link_to t(:edit), url
  end

  def core_field_list_item(core_field, disease=nil, &block)
    cf_class = "cf-#{core_field.field_type}"
    cf_class << " roll" unless core_field.tab?
    cf_class << " not-rendered" if core_field.hidden?(disease)
    options = { :class => cf_class }
    content_tag :li, options, &block
  end

  def core_field_rendered_label(disease=nil)
    label_text = disease ? t(:display_on, :disease => disease.disease_name) : t(:display_by_default)
    label_tag "core_field[rendered_attributes][rendered]", label_text, :style => "display: inline"
  end

  def core_field_buttons(core_field, disease=nil)
    <<-HTML
      <div class="#{core_field_buttons_class(core_field, disease)}">
        <a class="#{core_field_hide_button_class(core_field, disease)}">
          #{t :hide}
        </a>
        <a class="#{core_field_display_button_class(core_field, disease)}">
          #{t :display}
        </a>
        #{image_tag('redbox_spinner.gif', :class => 'ui-helper-hidden', :alt => 'Working...')}
      </div>
    HTML
  end

  def core_field_buttons_class(core_field, disease=nil)
    result = ['core_field_buttons']
    result << 'ui-helper-hidden' if core_field.required?
    result << 'hidden_by_ancestry' if core_field.hidden_by_ancestry?(disease)
    result.join(' ')
  end

  def core_field_hide_button_class(core_field, disease)
    result = ['hide button']
    result << 'ui-helper-hidden' unless core_field.rendered?(disease)
    result.join(' ')
  end

  def core_field_display_button_class(core_field, disease)
    result = ['display button']
    result << 'ui-helper-hidden' if core_field.rendered?(disease)
    result.join(' ')
  end

end
