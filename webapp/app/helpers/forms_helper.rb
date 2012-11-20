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

module FormsHelper
  extensible_helper

  # Converts a class name (of a form element type) into the render_* helper method that
  # renders it.
  def render_method(class_name)
    ('render_' << class_name.underscore.gsub('_element', '')).to_sym
  end

  def render_element(form_elements_cache, element, include_children=true)
    send(render_method(element.class.name), form_elements_cache, element, include_children)
  end

  def render_admin_elements(container_element, include_children=true)
    form_elements_cache = container_element.form.form_element_cache

    returning "" do |result|
      form_elements_cache.children(container_element).each do |child|
        result << render_element(form_elements_cache, child, include_children)
      end
    end
  end
  
  def render_view(form_elements_cache, element, include_children=true)
    begin
      result = "<li id='view_#{element.id}' class='sortable fb-tab'>"

      result << "<table><tr>"
      result << "<td class='tab'>#{h(element.name)}</td>"
      result << "<td class='actions'>" << add_section_link(element, t("tab"))
      result << "&nbsp;&nbsp;" << add_question_link(element, t("tab"))
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, t("tab"), true)
      result << "&nbsp;&nbsp;" << delete_view_link(element)
      result << "</td></tr></table>"

      result << "<div id='section-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='follow-up-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='view_#{h(element.id.to_s)}_children'  class='fb-tab-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("view_#{element.id}_children", element, :only => 'sortable')
      end

      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('view_element')
    end
  end

  def render_core_view(form_elements_cache, element, include_children=true)
    begin
      result = "<li id='core_view_#{h(element.id)}' class='fb-tab'>"

      result << "<table><tr>"
      result << "<td class='tab'>#{h(I18n.t("core_views.#{element.name.downcase}"))}</td>"
      result << "<td class='actions'>" << add_section_link(element, "tab")
      result << "&nbsp;&nbsp;" << add_question_link(element, "tab")
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, "tab", true)
      result << "&nbsp;&nbsp;" << delete_view_link(element)
      result << "</td></tr></table>"

      result << "<div id='section-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='follow-up-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='view_#{h(element.id.to_s)}_children' class='fb-tab-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("view_#{h(element.id)}_children", element)
      end

      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('core_view_element')
    end
  end

  def event_field(element)
    event_type = element.form.event_type
    CoreField.event_fields(event_type)[element.core_path]
  end

  def render_core_field(form_elements_cache, element, include_children=true)
    begin
      result = "<li id='core_field_#{h(element.id)}' class='fb-core-field' style='clear: both;'>"

      if event_field(element).nil?
        result << "<b style='color: #CC0000;'>#{t("invalid_core_field_config")} #{h(element.name)}</b><br/><small>Invalid core field path is: #{h(element.core_path)}</small>"
      else
        result << "<table><tr>"
        result << "<td class='tab'>#{h(element.name)}"
        result << "<span class=\"cdc_export_info\" id=\"cdc-export-info-#{h(element.id)}\" "
        result << "style=\"display: none;\"" if element.export_column_id.nil?
        result << ">&nbsp;&nbsp;<em>(#{t('exporting_to_cdc')})</em></span>"
        result << "</td>"
      end

      result << "<td class='actions'>"
      result << include_in_cdc_export_link(element) << ("&nbsp;"*2)
      result << delete_core_field_link(element)
      result << "</td></tr>"
      result << "<tr>"
      result << "<td colspan=\"2\">"
      result << "<span id=\"cdc-export-for-#{h(element.id)}\" style=\"display: none;\">"
      result << core_field_cdc_select(element) + '</span>'
      result << "</td></tr></table>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='core_field_#{h(element.id.to_s)}_children' class='fb-core-field-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
      end

      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('core_field_element')
    end
  end

  def render_before_core_field(form_elements_cache, element, include_children)
    begin
      result = "<li id='before_core_field_#{h(element.id)}' class='fb-before-core-field'>"

      result << "<table><tr>"
      result << "<td class='field'>#{t('before_configuration')}</td>"
      result << "<td class='actions'>" << add_question_link(element, t("before_config"))
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, t("before_config"), true)
      result << "</td></tr></table>"

      result << "<div id='follow-up-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='before_core_field_#{h(element.id.to_s)}_children' class='fb-before-core-field-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("before_core_field_#{h(element.id)}_children", element)
      end

      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"
      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('before_core_field')
    end
  end

  def render_after_core_field(form_elements_cache, element, include_children)
    begin
      result = "<li id='after_core_field_#{h(element.id)}' class='fb-after-core-field'>"

			result << "<table><tr>"
      result << "<td class='field'>#{t('after_configuration')}</td>"
      result << "<td class='actions'>" << add_question_link(element, t("after_config"))
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, t("after_config"), true)
      result << "</td></tr></table>"

      result << "<div id='follow-up-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='after_core_field_#{h(element.id.to_s)}_children' class='fb-after-core-field-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("after_core_field_#{h(element.id)}_children", element)
      end

      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"
      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('after_core_field')
    end
  end

  def render_section(form_elements_cache, element, include_children=true)
    begin
      result = "<ul id='section_#{h(element.id)}' class='sortable fb-section'>"
      result << "<table><tr>"
      result << "<td class='section'>#{h(strip_tags(element.name))}</td>"
      result << "<td class='actions'>"
      result << edit_section_link(element)
      result << "&nbsp;&nbsp;" << add_question_link(element, t("section")) if (include_children)
      result << "&nbsp;&nbsp;" << delete_section_link(element)
      result << "</td></tr>"
      result << "<tr><td colspan='2' class='instructions'>#{sanitize(h(element.description).gsub("\n", '<br/>'), :tags => %w(br))}</td></tr>" unless element.description.blank?
      result << "</table>"

      result << "<div id='section-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='section_#{h(element.id.to_s)}_children' class='fb-section-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("section_#{h(element.id)}_children", element)
      end

      result << "</ul>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('section_element')
    end
  end

  def render_group(form_elements_cache, element, include_children=true)
    begin
      result = "<ul id='group_#{h(element.id)}' class='sortable fb-group'>"

      result << "<table><tr>"
      result << "<td class='group'>#{h(element.name)}</td>"
      result << "<td class='actions'>" << delete_group_link(element)
      result << "</td></tr></table>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='section_#{h(element.id.to_s)}_children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("section_#{h(element.id)}_children", element)
      end

      result << "</ul>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('group_element')
    end
  end

  def render_question(form_elements_cache, element, include_children=true)
    begin
      question = element.question
      question_id = "question_#{h(element.id)}"

      result = "<li id='#{h(question_id)}' class='sortable question'>"

      result << "<table><tr>"
      result << "<td class='question label' style='text-transform: capitalize;'>#{t('question')}</td>"
      result << "<td class='question actions'>" << edit_question_link(element)
      result << "&nbsp;&nbsp;" << add_follow_up_link(element)
      result << "&nbsp;&nbsp;" << add_to_library_link(element) if (include_children)
      result << "&nbsp;&nbsp;" << add_value_set_link(element) if include_children && element.is_multi_valued_and_empty? && element.export_column_id.blank?
      result << "&nbsp;&nbsp;" << delete_question_link(element)
      result << "</td></tr></table>"

      result << "#{sanitize(question.question_text, :tags => %w(br))}"
      result << "&nbsp;&nbsp;<small>["
      result << "#{h(question.short_name)}, " unless question.short_name.blank?
      result << h(I18n.t("question_data_types.#{question.data_type_before_type_cast}"))
      result << "&nbsp;, inactive" unless element.is_active
      result << "&nbsp;, CDC value" unless element.export_column_id.blank?
      result  << "]</small>"

      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='library-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='follow-up-mods-#{h(element.id.to_s)}'></div>"
      result << "<div id='value-set-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='question_#{h(element.id.to_s)}_children' class='fb-question-children'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
      end

      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('question_element')
    end
  end

  def render_follow_up(form_elements_cache, element, include_children=true)
    begin
      result = "<ul class='follow-up-item sortable' id='follow_up_#{h(element.id)}'>"

      result << "<table><tr>"
      result << "<td class='followup'>"

      if element.core_path.blank?
        thing = "#{ct('condition')} <b>#{h(element.condition)}</b>"
        result << t('follow_up_on', :thing => thing)
      else
        if element.is_condition_code
          code = ExternalCode.find(element.condition)
          thing = "#{ct('code_condition')} #{h(code.code_description)} (#{h(code.code_name)})"
        else
          thing = "<b>#{h(element.condition)}</b><br/>"
        end
        result << t('core_follow_up_on', :thing => thing)
      end

      unless (element.core_path.blank?)
        if (field = event_field(element)).nil?
          result << t('next_item', :item => "<b>#{t('invalid_code_data_element')}</b>")
          result << "<br/>"
          result << "<small>#{t('invalid_core_field_path_is', :thing => h(element.core_path))}</small><br/>"
        else
          result << "&nbsp;"
          result << t('core_data_element', :thing => "<b>#{h(field.name)}</b>")
        end
      end

      result << "</td>"
      result << "<td class='actions'>"
      if (include_children)
        result << " " << add_question_link(element, t("follow_up_container"))
        result << "&nbsp;&nbsp;" << edit_follow_up_link(element, !element.core_path.blank?)
        result << "&nbsp;&nbsp;" << delete_follow_up_link(element)
        result << "</td></tr></table>"
      end

      result << "<div id='follow-up-mods-#{h(element.id.to_s)}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='follow_up_#{h(element.id.to_s)}_children' class='fb-follow-up-children'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_fb_element("follow_up_#{h(element.id)}_children", element)
      end

      result << "<div id='question-mods-#{h(element.id.to_s)}'></div>"
      result << "</ul>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('follow_up_element')
    end
  end

  def sortable_fb_element(html_id, element, options = {})
    %Q{<script>
      $j("##{h(html_id)}").sortable({
        update: function(event, ui) {
          $j.ajax({
            type: 'put',
            data: $j('##{h(html_id)}').sortable('serialize'),
            complete: function(request){
              $j('##{h(html_id)}').effect('highlight');
            },
            url: "#{order_section_children_path(element)}"
          })
        }
      });
    </script>
    }
  end

  def order_section_children_path(element)
    url_for(:controller => :forms, :action => :order_section_children, :id => element.id)
  end

  def render_value_set(form_elements_cache, element, include_children=true)
    begin
      value_set_style = element.export_column_id.blank? ? "fb-value-set" : "fb-cdc-value-set"
      result =  "<li id='value_set_#{h(element.id.to_s)}' class='#{h(value_set_style)}'>"

      result << "<table><tr>"
      result << "<td class='valueset'>Value Set: "
      result << "<b>" << h(element.name) << "</b>"
      result << "</td>"

      result << "<td class='actions'>"
      if include_children
        result << edit_value_set_link(element) if (element.export_column_id.blank?)
        result << "&nbsp;&nbsp;" << add_value_link(element) if (element.export_column_id.blank?)
        result << "&nbsp;&nbsp;" << add_to_library_link(element) if (element.export_column_id.blank? && (form_elements_cache.children?(element) > 0))
      end

      result << "&nbsp;&nbsp;" << delete_value_set_link(element) if (element.export_column_id.blank?)
      result << "</td></tr></table>"

      result << "<div id='library-mods-#{h(element.id.to_s)}'></div>" if include_children
      result << "<div id='value-set-mods-#{h(element.id.to_s)}'></div>" if include_children
      result << "<div id='value-mods-#{h(element.id.to_s)}'></div>" if include_children

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='value_set_#{h(element.id.to_s)}_children' class='fb-value-set-children'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
      end

      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('value_set_element')
    end
  end

  def render_value(form_elements_cache, element, include_children=true)
    begin
      result =  "<li id='value_#{h(element.id.to_s)}' class='fb-value'>"
      result << "<span class='inactive-value'>" unless element.is_active
      if element.name.blank?
        result << "<i color='#999999'>#{t('blank')}</i>"
      else
        result << h(element.name)
      end

      result << "&nbsp;&nbsp;<i>(#{t('inactive')})</i></span>" unless element.is_active
      result << "&nbsp;&nbsp;" << toggle_value_link(element)
      result << "&nbsp;&nbsp;" << edit_value_link(element) if (element.export_conversion_value_id.blank?)
      result << "&nbsp;&nbsp;" << delete_value_link(element) if (element.export_conversion_value_id.blank?)
      result << "<div id='value-mods-#{h(element.id.to_s)}'></div>" if include_children
      result << "</li>"
      return result
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.join("\n"))
      could_not_render element, t('value_element')
    end
  end

  def admin_master_info(form)
    date_format = '%B %d, %Y %I:%M %p'
    result = ""
    result << "<h2 style=\"text-transform: capitalize;\">#{t('master_copy')}</h2>"
    result << "#{h(t('form_specific.element', :count => form.element_count))}<br/>"
    result << "#{h(t('form_specific.question', :count => form.question_count))}<br/>"
    result << "#{h(t('form_specific.element', :count => form.core_element_count))} with ties to core fields<br/>"
    result << "#{h(t('form_specific.cdc_export_question', :count => form.cdc_question_count))}<br/>"
    result << "#{ct('form_created_at')} #{ld(form.created_at, {:format => :date_format})}<br/>"
    result << "#{ct('form_last_updated')} #{ld(form.updated_at, {:format => :date_format})}<br/>"
    result << "#{ct('elements_last_updated')} #{ld(form.elements_last_updated, {:format => :date_format})}"
    result
  end

  def admin_version_info(form)
    result = ""
    published_versions = form.published_versions
    result << "<h2>#{t('published_versions')}</h2>"

    if published_versions.size == 0
      result << t('no_published_versions')
      return result
    end

    result << "<table class='list'>"
    result << "<tr><th>#{t('version')}</th><th>#{t('published')}</th><th>#{t('diseases')}</th><th>#{t('form_metadata')}</th><th>&nbsp;</th></tr>"

    form.published_versions.each do |published_form|
      result << render(:partial => 'admin_version_info', :locals => {:form => published_form})
    end

    result << "</table>"
    result
  end

  def follow_up_select_options(event_type)
    CoreField.event_fields(event_type).select{|k,v| v.can_follow_up}.map{|k,v| [v.name, k]}.sort_by(&:first)
  end

  def form_event_type_options_for_select(form)
    options_for_select(form_event_types, form.event_type)
  end

  def form_event_types
    [
     [t("morbidity_event"), "morbidity_event"],
     [t("assessment_event"), "assessment_event"],
     [t("contact_event"), "contact_event"],
     [t("place_event"), "place_event"],
     [t("encounter_event"), "encounter_event"],
     [t("morbidity_and_assessment_event"), "morbidity_and_assessment_event"]
    ]
  end

  def include_in_cdc_export_link(element)
    link = link_to_function(t('add_to_cdc_export'), nil, :id => "cdc-export-#{h(element.id.to_s)}") do |page|
      page.toggle("cdc-export-for-#{h(element.id)}")
    end
    "<small>#{link}</small>"
  end

  def delete_view_link(element)
    options = fb_html_options :delete, :view, element
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def add_section_link(element, trailing_text)
    options = fb_html_options(:add, :section, element).merge(:name => 'add-section')
    text = t('add_section_to', :thing => trailing_text)
    path = new_section_element_path(:form_element_id => element)
    fb_ajax_link(path, text, {:method => :post}, options)
  end

  def edit_section_link(element)
    options = fb_html_options(:edit, :section, element)
    path = edit_section_element_path(element)
    fb_ajax_link(path, t('edit'), {:method => :get}, options)
  end

  def delete_section_link(element)
    options = fb_html_options(:delete, :section, element)
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def delete_group_link(element)
    options = fb_html_options(:delete, :group, element)
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def delete_follow_up_link(element)
    options = fb_html_options(:delete, 'follow-up', element)
    options.merge!(:id => "delete-follow-up-#{element.id}")
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def add_question_link(element, trailing_text)
    options = fb_html_options(:add, :question, element)
    path = new_question_element_path(:form_element_id => element)
    txt = t('add_question_to', :thing => h(trailing_text))
    fb_ajax_link(path, txt, {:method => :post}, options)
  end

  def edit_question_link(element)
    options = fb_html_options(:edit, :question, element)
    path = edit_question_element_path(element)
    fb_ajax_link(path, t('edit'), {:method => :get}, options)
  end

  def delete_question_link(element)
    options = fb_html_options(:delete, :question, element)
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def delete_core_field_link(element)
    options = fb_html_options(:delete, 'core-field', element)
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def add_follow_up_link(element, trailing_text = "", core_data = false)
    if element.try(:core_field_element).try(:core_field).try(:repeater?)
      ""
    else
      options = fb_html_options(:add, 'follow-up', element).merge(:name => 'add-follow-up')
      path_options = {:form_element_id => element}
      path_options.merge!({:core_data => true, :event_type => h(@form.event_type)}) if core_data
      path = new_follow_up_element_path(path_options)
      txt = (trailing_text.blank? ? t('add_follow_up') : t('add_follow_up_to', :thing => trailing_text))
      fb_ajax_link(path, txt, {:method => :post}, options)
    end
  end

  def edit_follow_up_link(element, core_data)
    options = fb_html_options(:edit, 'follow-up', element)
    path_options = core_data ? {:core_data => true, :event_type => h(@form.event_type)} : {}
    path = edit_follow_up_element_path(element, path_options)
    fb_ajax_link(path, t('edit'), {:method => :get}, options)
  end

  def add_to_library_link(element)
    "<small>" << link_to_remote(t("copy_to_library"),
      :url => {
        :controller => "group_elements", :action => "new", :form_element_id => element.id},
      :html => {
        :class => "fb-add-to-library",
        :id => "add-element-to-library-#{h(element.id)}"
      }
    ) << "</small>"
  end

  def add_value_set_link(element)
    options = fb_html_options(:add, 'value-set', element)
    path = new_value_set_element_path(:form_element_id => element, :form_id => h(element.form_id.to_s))
    fb_ajax_link(path, t('add_value_set'), {:method => :post}, options)
  end

  def edit_value_set_link(element)
    options = fb_html_options(:edit, 'value-set', element)
    path = edit_value_set_element_path(element)
    fb_ajax_link(path, t('edit_value_set'), {:method => :get}, options)
  end

  def delete_value_set_link(element)
    options = fb_html_options(:delete, 'value-set', element)
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def add_value_link(element)
    options = fb_html_options(:add, :value, element)
    path = new_value_element_path(:form_element_id => element)
    fb_ajax_link(path, t('add_value'), {:method => :get}, options)
  end

  def edit_value_link(element)
    options = fb_html_options(:edit, :value, element)
    path = edit_value_element_path(element)
    fb_ajax_link(path, t('edit'), {:method => :get}, options)
  end

  def delete_value_link(element)
    options = fb_html_options(:delete, :value, element)
    path = form_element_path(element)
    fb_ajax_link(path, delete_img, delete_options, options)
  end

  def toggle_value_link(element)
    path = toggle_value_path(element)
    txt = element.is_active ? t('inactivate') : t('activate')
    fb_ajax_link path, txt, {:method => :post}
  end

  def core_field_cdc_select(element)
    export_columns = ExportColumn.core_export_columns_for(element.form.disease_ids)
    if export_columns.empty?
      result = t('fb_no_cdc_columns')
    else
      options_tags = "<option value=\"\"></option>"
      options_tags +=  export_columns.collect do |column|
        result =  "<option value=\"#{h(column.id)}\" "
        result << "select=\"select\" " if element.export_column_id == column.id
        result << ">#{h(column.name)}</option>"
      end.join(' ')
      result = select_tag("core-export-columns-#{h(element.id)}", options_tags, :onchange => set_export_column_on(element))
      result << image_tag('redbox_spinner.gif', :alt => t('spinner_alt'), :id => "core_export_#{h(element.id)}_spinner", :style => 'display: none;')
    end
    result
  end

  def publish_form_button
    result =  form_remote_tag(:url => {:action => 'publish', :id => @form.id},
                    :loading => "$('publish_btn').disabled = 'disabled';$('publish_btn').value = '#{t('publishing')}';$('spinner').show();",
                    :complete => "$('publish_btn').value = '#{t('publish')}'; $('spinner').hide();")
    result << submit_tag(t('publish'), :id => 'publish_btn', :class => 'form_button')
    result << image_tag('redbox_spinner.gif', :id => 'spinner', :style => "height: 16px; width: 16px; display: none;")
    result << "</form>"
    result
  end

  def set_export_column_on(element)
    path = update_export_column_form_element_path(element)
    <<-UPDATE_EXPORT_COLUMN.gsub(/\s+/, ' ')
      new Ajax.Request('#{path}', {
        asynchronous:true,
        evalScripts:true,
        parameters: {export_column_id: $F(this)},
        onCreate: function(){$('core_export_#{h(element.id)}_spinner').show()},
        onComplete: function(){$('core_export_#{h(element.id)}_spinner').hide()}});
      return false;
    UPDATE_EXPORT_COLUMN
  end

  def fb_ajax_link(path, link_content, options={}, html_options={})
    js = fb_ajax_req(path, options)
    link = link_to_function link_content, js, html_options
    "<small>#{link}</small>"
  end

  def fb_ajax_req(path, options={})
    returning "" do |result|
      result << "if (confirm('#{options[:confirm]}')) { " if options[:confirm]
      result << "  new Ajax.Request('#{path}', { "
      result << "    asynchronous: true, "
      result << "    evalScripts: true, "
      result << "    method: '#{options[:method] || :post}'"
      result << "  }); "
      result << "};" if options[:confirm]
    end
  end

  def delete_options
    {:method => :delete, :confirm => t('confirm_remove_element')}
  end

  def fb_html_options(action, type, element)
    clazz = "#{action}-#{type}"
    { :class => clazz, :id => "#{clazz}-#{h element.id.to_s}" }
  end

  def delete_img
    image_tag("delete.png", :border => 0, :alt => t('delete'))
  end

  def could_not_render(element, type)
    "<li>#{t('could_not_render', :thing => type, :id => element.id)}</li>"
  end

  def link_to_show_all_groups(reference_element, type)
    link_to_remote(t(:show_all_groups),
                   :url => {
                     :controller => 'form_elements',
                     :action => 'filter_elements',
                     :reference_element_id => reference_element.id,
                     :direction => :from_library,
                     :type => type },
                   :update => "library-element-list-#{reference_element.id}")
  end

  def remote_form_for_fixing_short_names(reference_element, &block)
    options = {
      :url => url_for(:controller => :forms, :action => :from_library),
      :loading => "$('submit_short_name_fix_#{reference_element.id}').disable()"
    }
    form_remote_tag(options, &block)
  end

  def replacement_short_name_fields(question)
    returning [] do |result|
      result << (question.collision ? "<div class='fieldWithErrors'>" : "<span>")
      result << label_tag(replacement_field_id(question),
                          question.question_text)
      result << text_field_tag(replacement_field_name(question),
                               question.short_name,
                               :id => replacement_field_id(question))
      result << (question.collision ? "</div>" : "</span>")
    end.join("\n")
  end

  def replacement_field_id(question)
    "replacements_#{question.id}_short_name"
  end

  def replacement_field_name(question)
    "replacements[#{question.id}][short_name]"
  end

  def short_name_collision_error_message(compare_results)
    contents = ''
    contents << content_tag(:h2, t(:fix_short_names))
    contents << content_tag(:p,  t(:question_short_names_in_use))
    short_name_fails = compare_results.inject(0) do |sum, q|
      sum += 1 if q.collision
      sum
    end
    contents << content_tag(:ul, "<li>#{t(:x_short_names_need_fixed, :count => short_name_fails)}</li>")

    content_tag(:div, contents, :id => 'errorExplanation', :name => 'errorExplanation')
  end

end
