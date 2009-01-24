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

module FormsHelper
  
  def render_admin_elements(container_element, include_children=true)
    form_elements_cache = container_element.form.form_element_cache
    
    result = ""
    
    form_elements_cache.children(container_element).each do |child|
      result << render_element(form_elements_cache, child, include_children)
    end
    
    result
  end
  
  def render_element(form_elements_cache, element, include_children=true)
    
    case element.class.name
    when "ViewElement"
      render_view(form_elements_cache, element, include_children)
    when "CoreViewElement"
      render_core_view(form_elements_cache, element, include_children)
    when "CoreFieldElement"
      render_core_field(form_elements_cache, element, include_children)
    when "BeforeCoreFieldElement"
      render_before_core_field(form_elements_cache, element, include_children)
    when "AfterCoreFieldElement"
      render_after_core_field(form_elements_cache, element, include_children)
    when "SectionElement"
      render_section(form_elements_cache, element, include_children)
    when "GroupElement"
      render_group(form_elements_cache, element, include_children)
    when "QuestionElement"
      render_question(form_elements_cache, element, include_children)
    when "FollowUpElement"
      render_follow_up(form_elements_cache, element, include_children)
    when "ValueSetElement"
      render_value_set(form_elements_cache, element, include_children)
    when "ValueElement"
      render_value(form_elements_cache, element, include_children)
    end

  end
  
  def render_view(form_elements_cache, element, include_children=true)
    begin
      result = "<li id='view_#{element.id}' class='sortable fb-tab'>"
      
      result << "<table><tr>"
      result << "<td class='tab'>#{element.name}</td>"
      result << "<td class='actions'>" << add_section_link(element, "tab")
      result << "&nbsp;&nbsp;" << add_question_link(element, "tab")
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, "tab", true)
      result << "&nbsp;&nbsp;" << delete_view_link(element)
      result << "</td></tr></table>"
    
      result << "<div id='section-mods-#{element.id.to_s}'></div>"
      result << "<div id='follow-up-mods-#{element.id.to_s}'></div>"
      result << "<div id='question-mods-#{element.id.to_s}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='view_#{element.id.to_s}_children'  class='fb-tab-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("view_#{element.id}_children", :constraint => :vertical, :only => "sortable", :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "</li>"
      return result
    rescue
      return "<li>Could not render view element (#{element.id})</li>"
    end
  end
  
  def render_core_view(form_elements_cache, element, include_children=true)
    begin
      result = "<li id='core_view_#{element.id}' class='fb-tab'>"
    
      result << "<table><tr>"
      result << "<td class='tab'>#{element.name}</td>"
      result << "<td class='actions'>" << add_section_link(element, "tab")
      result << "&nbsp;&nbsp;" << add_question_link(element, "tab")
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, "tab", true)
      result << "&nbsp;&nbsp;" << delete_view_link(element)
      result << "</td></tr></table>"
    
      result << "<div id='section-mods-#{element.id.to_s}'></div>"
      result << "<div id='follow-up-mods-#{element.id.to_s}'></div>"
      result << "<div id='question-mods-#{element.id.to_s}'></div>"
    
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='view_#{element.id.to_s}_children' class='fb-tab-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("view_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "</li>"
      return result
    rescue
      return "<li>Could not render core view element (#{element.id})</li>"
    end
  end
  
  def render_core_field(form_elements_cache, element, include_children=true)
    begin
      result = "<li id='core_field_#{element.id}' class='fb-core-field' style='clear: both;'>"
      
      exposed_attributes = eval(element.form.event_type.camelcase).exposed_attributes
         
      if exposed_attributes[element.core_path].nil?
        result << "<b style='color: #CC0000;'>Core field configuration is invalid: #{element.name}</b><br/><small>Invalid core field path is: #{element.core_path}</small>"
      else
        result << "<table><tr>"
        result << "<td class='tab'>#{element.name}"        
        result << "<span class=\"cdc_export_info\" id=\"cdc-export-info-#{element.id}\" "
        result << "style=\"display: none;\"" if element.export_column_id.nil?
        result << ">&nbsp;&nbsp;<em>(exporting to CDC)</em></span>"
        result << "</td>"
      end

      result << "<td class='actions'>"
      result << include_in_cdc_export_link(element) << ("&nbsp;"*2)
      result << delete_core_field_link(element)
      result << "</td></tr>"
      result << "<tr>"
      result << "<td colspan=\"2\">"
      result << "<span id=\"cdc-export-for-#{element.id}\" style=\"display: none;\">"
      result << core_field_cdc_select(element) + '</span>'
      result << "</td></tr></table>"
      
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='core_field_#{element.id.to_s}_children' class='fb-core-field-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
      end
    
      result << "</li>"
      return result
    rescue
      return "<li>Could not render core field element (#{element.id})</li>"
    end
  end
  
  def render_before_core_field(form_elements_cache, element, include_children)
    begin
      result = "<li id='before_core_field_#{element.id}' class='fb-before-core-field'>"
    
      result << "<table><tr>"
      result << "<td class='field'>Before configuration</td>"
      result << "<td class='actions'>" << add_question_link(element, "before config")
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, "before config", true)
      result << "</td></tr></table>"
      
      result << "<div id='follow-up-mods-#{element.id.to_s}'></div>"
    
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='before_core_field_#{element.id.to_s}_children' class='fb-before-core-field-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("before_core_field_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "<div id='question-mods-#{element.id.to_s}'></div>"
      result << "</li>"
      return result
    rescue
      return "<li>Could not render before core field element (#{element.id})</li>"
    end
  end
    
  def render_after_core_field(form_elements_cache, element, include_children)
    begin
      result = "<li id='after_core_field_#{element.id}' class='fb-after-core-field'>"
    
			result << "<table><tr>"
      result << "<td class='field'>After configuration</td>"
      result << "<td class='actions'>" << add_question_link(element, "after config")
      result << "&nbsp;&nbsp;" << add_follow_up_link(element, "after config", true)
      result << "</td></tr></table>"
      
      result << "<div id='follow-up-mods-#{element.id.to_s}'></div>"
    
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='after_core_field_#{element.id.to_s}_children' class='fb-after-core-field-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("after_core_field_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "<div id='question-mods-#{element.id.to_s}'></div>"
      result << "</li>"
      return result
    rescue
      return "<li>Could not render after core field element (#{element.id})</li>"
    end
  end
  
  def render_section(form_elements_cache, element, include_children=true)
    begin
      result = "<ul id='section_#{element.id}' class='sortable fb-section'>"
      result << "<table><tr>"
      result << "<td class='section'>#{strip_tags(element.name)}</td>"
      result << "<td class='actions'>" 
      result << edit_section_link(element)
      result << "&nbsp;&nbsp;" << add_question_link(element, "section") if (include_children)
      result << "&nbsp;&nbsp;" << delete_section_link(element)
      result << "</td></tr>"
      result << "<tr><td colspan='2' class='instructions'>#{sanitize(element.description.gsub("\n", '<br/>'), :tags => %w(br))}</td></tr>" unless element.description.blank?
      result << "</table>"
    
      result << "<div id='section-mods-#{element.id.to_s}'></div>"
      result << "<div id='question-mods-#{element.id.to_s}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='section_#{element.id.to_s}_children' class='fb-section-children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("section_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "</ul>"
      return result
    rescue
      return "<li>Could not render section element (#{element.id})</li>"
    end
  end

  def render_group(form_elements_cache, element, include_children=true)
    begin
      result = "<ul id='group_#{element.id}' class='sortable fb-group'>"
      
      result << "<table><tr>"
      result << "<td class='group'>#{element.name}</td>"
      result << "<td class='actions'>" << delete_group_link(element)
      result << "</td></tr></table>"
    
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='section_#{element.id.to_s}_children' style='clear: both'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("section_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "</ul>"
      return result
    rescue
      return "<li>Could not render group element (#{element.id})</li>"
    end
  end
 
  def render_question(form_elements_cache, element, include_children=true)
    begin
      question = element.question
      question_id = "question_#{element.id}"
    
      result = "<li id='#{question_id}' class='sortable question'>"

      result << "<table><tr>"
      result << "<td class='question label'>Question</td>"
      result << "<td class='question actions'>" << edit_question_link(element) 
      result << "&nbsp;&nbsp;" << add_follow_up_link(element) unless (question.data_type_before_type_cast == "check_box") 
      result << "&nbsp;&nbsp;" << add_to_library_link(element) if (include_children)  
      result << "&nbsp;&nbsp;" << add_value_set_link(element) if include_children && element.is_multi_valued_and_empty? && element.export_column_id.blank?
      result << "&nbsp;&nbsp;" << delete_question_link(element)
      result << "</td></tr></table>"
      
      result << "#{sanitize(question.question_text, :tags => %w(br))}"
      result << "&nbsp;&nbsp;<small>[" 
      result << "#{question.short_name}, " unless question.short_name.blank?
      result << question.data_type_before_type_cast.humanize
      result << "&nbsp;, inactive" unless element.is_active
      result << "&nbsp;, CDC value" unless element.export_column_id.blank?
      result  << "]</small>"
      
      result << "<div id='question-mods-#{element.id.to_s}'></div>"
      result << "<div id='library-mods-#{element.id.to_s}'></div>"
      result << "<div id='follow-up-mods-#{element.id.to_s}'></div>"
      result << "<div id='value-set-mods-#{element.id.to_s}'></div>"

      if include_children && form_elements_cache.children?(element)
        result << "<ul id='question_#{element.id.to_s}_children' class='fb-question-children'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
      end
    
      result << "</li>"
      return result
    rescue
      return "<li>Could not render question element (#{element.id})</li>"
    end
  end

  def render_follow_up(form_elements_cache, element, include_children=true)
    begin
      result = "<ul class='follow-up-item sortable' id='follow_up_#{element.id}'>"
      
      result << "<table><tr>"
      result << "<td class='followup'>"
      
      exposed_attributes = eval(element.form.event_type.camelcase).exposed_attributes
    
      if (element.core_path.blank?)
        result <<  "Follow up, Condition: <b>#{element.condition}</b>"
      else
        result <<  "Core follow up, "
        if (element.is_condition_code)
          code = ExternalCode.find(element.condition)
          result <<  "Code condition: #{code.code_description} (#{code.code_name})"
        else
          result <<  "<b>#{element.condition}</b>"
          result << "<br>"
        end
      end
    
      unless (element.core_path.blank?)
        if exposed_attributes[element.core_path].nil?
          result << ", <b>Core data element is invalid</b><br/><small>Invalid core field path is: #{element.core_path}</small><br/>"
        else
          result << "&nbsp;Core data element: <b>#{exposed_attributes[element.core_path][:name]}</b>" 
        end
      end
    
      result << "</td>"
      result << "<td class='actions'>"
      if (include_children)
        result << " " << add_question_link(element, "follow up container")
        result << "&nbsp;&nbsp;" << edit_follow_up_link(element, !element.core_path.blank?)
        result << "&nbsp;&nbsp;" << delete_follow_up_link(element)
        result << "</td></tr></table>"
      end
      
      result << "<div id='follow-up-mods-#{element.id.to_s}'></div>"
    
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='follow_up_#{element.id.to_s}_children' class='fb-follow-up-children'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
        result << sortable_element("follow_up_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
      end
    
      result << "<div id='question-mods-#{element.id.to_s}'></div>"
      result << "</ul>"
      return result
    rescue
      return "<li>Could not render follow-up element (#{element.id})</li>"
    end
  end
  
  def render_value_set(form_elements_cache, element, include_children=true)
    begin
      value_set_style = element.export_column_id.blank? ? "fb-value-set" : "fb-cdc-value-set"
      result =  "<li id='value_set_#{element.id.to_s}' class='#{value_set_style}'>"
      
      result << "<table><tr>"
      result << "<td class='valueset'>Value Set: "
      result << "<b>" << element.name << "</b>"
      result << "</td>"
    
      result << "<td class='actions'>"
      if include_children
        result << edit_value_set_link(element) if (element.export_column_id.blank?)
        result << "&nbsp;&nbsp;" << add_to_library_link(element) if (element.export_column_id.blank?)
      end
    
      result << "&nbsp;&nbsp;" << delete_value_set_link(element) if (element.export_column_id.blank?)
      result << "</td></tr></table>"
    
      result << "<div id='library-mods-#{element.id.to_s}'></div>" if include_children
      result << "<div id='value-set-mods-#{element.id.to_s}'></div>" if include_children
    
      if include_children && form_elements_cache.children?(element)
        result << "<ul id='value_set_#{element.id.to_s}_children' class='fb-value-set-children'>"
        form_elements_cache.children(element).each do |child|
          result << render_element(form_elements_cache, child, include_children)
        end
        result << "</ul>"
      end
    
      result << "</li>"
      return result
    rescue
      return "<li>Could not render value set element (#{element.id})</li>"
    end
  end
  
  def render_value(form_elements_cache, element, include_children=true)
    begin
      result =  "<li id='value_#{element.id.to_s}' class='fb-value'>"
      result << "<span class='inactive-value'>" unless element.is_active
      if element.name.blank?
        result << "<i color='#999999'>Blank</i>"
      else
        result << element.name
      end
      
      result << "&nbsp;<i>(Inactive)</i></span>" unless element.is_active
      result << " " << toggle_value_link(element) << "</li>"
      return result
    rescue
      return "<li>Could not render value element (#{element.id})</li>"
    end
  end
  
  private

  def include_in_cdc_export_link(element)
    link = link_to_function("Add to CDC export", nil, :id => "cdc-export-#{element.id.to_s}") do |page|
      page.toggle("cdc-export-for-#{element.id}")
    end
    "<small>#{link}</small>"
  end
  
  def delete_view_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-view' id='delete-view-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Tab") << "</a>"
  end

  def add_section_link(element, trailing_text)
    "<small><a href='#' onclick=\"new Ajax.Request('../../section_elements/new?form_element_id=#{element.id.to_s}', {asynchronous:true, evalScripts:true}); return false;\" id='add-section-#{element.id.to_s}' class='add-section' name='add-section'>Add section to #{trailing_text}</a></small>"
  end
  
  def edit_section_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../section_elements/#{element.id.to_s}/edit', {asynchronous:true, evalScripts:true, method:'get'}); return false;\" id='edit-section-#{element.id.to_s}' class='edit-section'>Edit</a></small>"
  end
  
  def delete_section_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-section' id='delete-section-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Section") << "</a>"
  end
  
  def delete_group_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-group' id='delete-group-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Group") << "</a>"
  end
  
  def delete_follow_up_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-follow-up' id='delete-follow-up-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Follow Up") << "</a>"
  end
  
  def add_question_link(element, trailing_text)
    "<small><a href='#' onclick=\"new Ajax.Request('../../question_elements/new?form_element_id=#{element.id.to_s}&core_data=false" + "', {asynchronous:true, evalScripts:true}); return false;\" id='add-question-#{element.id.to_s}' class='add-question' name='add-question'>Add question to #{trailing_text}</a></small>"
  end
  
  def edit_question_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../question_elements/#{element.id.to_s}/edit', {asynchronous:true, evalScripts:true, method:'get'}); return false;\" class='edit-question' id='edit-question-#{element.id.to_s}'>Edit</a></small>"
  end
  
  def delete_question_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-question' id='delete-question-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Question") << "</a>"
  end
  
  def delete_core_field_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-core-field' id='delete-core-field-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Question") << "</a>"
  end
  
  def add_follow_up_link(element, trailing_text = "", core_data = false)
    result = "<small><a href='#' onclick=\"new Ajax.Request('../../follow_up_elements/new?form_element_id=#{element.id.to_s}"
    result <<  "&core_data=true&event_type=#{@form.event_type}" if (core_data)
    result << "', {asynchronous:true, evalScripts:true}); return false;\" id='add-follow-up-#{element.id.to_s}' class='add-follow-up' name='add-follow-up'>Add follow up"
    result << " to " << trailing_text unless trailing_text.empty?
    result << "</a></small>"
  end
  
  def edit_follow_up_link(element, core_data)
    result = "<small><a href='#' onclick=\"new Ajax.Request('../../follow_up_elements/#{element.id.to_s}/edit"
    result <<  "?core_data=true&event_type=#{@form.event_type}" if (core_data)
    result << "', {asynchronous:true, evalScripts:true, method:'get'}); return false;\" class='edit-follow-up' id='edit-follow-up-#{element.id.to_s}'>Edit</a></small>"
  end
  
  def add_to_library_link(element)
    "<small>" << link_to_remote("Copy to library", 
      :url => {
        :controller => "group_elements", :action => "new", :form_element_id => element.id}, 
      :html => {
        :class => "fb-add-to-library",
        :id => "add-element-to-library-#{element.id}"
      }
    ) << "</small>"
  end

  def add_value_set_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../value_set_elements/new?form_element_id=#{element.id.to_s}&form_id=#{element.form_id.to_s}', {asynchronous:true, evalScripts:true}); return false;\" class='add-value-set' id='add-value-set-#{element.id.to_s}'>Add value set</a></small>"
  end

  def edit_value_set_link(element)
    "<small><a class='fb-edit-value-set' href='#' onclick=\"new Ajax.Request('../../value_set_elements/#{element.id.to_s}/edit', {method:'get', asynchronous:true, evalScripts:true}); return false;\">Edit value set</a></small>"
  end
  
  def delete_value_set_link(element)
    "<a href='#' onclick=\"if (confirm('This action will delete this element and all children elements. Please confirm.')) { new Ajax.Request('../../form_elements/#{element.id.to_s}', {asynchronous:true, evalScripts:true, method:'delete'}); }; return false;\" class='delete-value-set' id='delete-value-set-#{element.id.to_s}'>" << image_tag("delete.png", :border => 0, :alt => "Delete Value Set") << "</a>"
  end
  
  def toggle_value_link(element)
    result = "<small><a href='#' onclick=\"new Ajax.Request('../../value_set_elements/toggle_value/#{element.id.to_s}', {asynchronous:true, evalScripts:true}); return false;\">"
    
    if (element.is_active)
      result << "Inactivate"
    else
      result << "Activate"
    end
    
    result << "</a></small>"
  end

  def core_field_cdc_select(element)
    export_columns = ExportColumn.core_export_columns_for(element.form.disease_ids)
    if export_columns.empty?
      result = "No core export columns have been associated with this form's diseases"
    else
      options_tags = "<option value=\"\"></option>"
      options_tags +=  export_columns.collect do |column|
        result =  "<option value=\"#{column.id}\" "
        result << "select=\"select\" " if element.export_column_id == column.id 
        result << ">#{column.name}</option>"
      end.join(' ')
      result = select_tag("core-export-columns-#{element.id}", options_tags, :onchange => set_export_column_on(element))
      result << image_tag('redbox_spinner.gif', :alt => 'Working...', :id => "core_export_#{element.id}_spinner", :style => 'display: none;')
    end
    result
  end

  def set_export_column_on(element)
    <<-UPDATE_EXPORT_COLUMN.gsub(/\s+/, ' ')
      new Ajax.Request('../../form_elements/update_export_column/#{element.id.to_s}', {asynchronous:true, evalScripts:true,
        parameters: {export_column_id: $F(this)},
        onCreate: function(){$('core_export_#{element.id}_spinner').show()},
        onComplete: function(){$('core_export_#{element.id}_spinner').hide()}});
      return false;
    UPDATE_EXPORT_COLUMN
  end
end
