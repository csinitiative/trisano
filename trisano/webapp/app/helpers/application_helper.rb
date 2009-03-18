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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def l(lookup_field)
    lookup_field.nil? ? nil : lookup_field.code_description 
  end

  def fml(pre, value_field, post)
    value_field.blank? ? nil : pre+value_field+post 
  end

  def phone_number(number)
    if number =~ /\d{7}/
      number = number[0,3] + "-" + number[3,4]
    elsif number =~ /\d{3}-\d{4}/
      number
    elsif number == ""
      ""
    else
      "! "+number
    end
  end
  
  def calculate_age(date)
    (Date.today - date).to_i / 365
  end

  def editable_content_tag(elemtype, obj, prop, editable, options = {}, editOptions = {}, ajaxOptions = {})
    objname = obj.class.to_s.downcase
    options[:url] = "/#{objname.pluralize}/#{obj.id}" unless options.has_key? :url
    options[:url] += '.json'
    options[:id] = dom_id(obj)+"_#{prop}" unless options.has_key? :id
    ajaxOptions[:method] = 'put'
    edops = jsonify editOptions
    ajops = jsonify ajaxOptions

    tg = content_tag  elemtype, 
      obj.send(prop),
      options = options

    if editable then
      tg += "
           <script type='text/javascript'>\n
               new Ajax.InPlaceEditor('#{options[:id]}', '#{options[:url]}', { 
                        ajaxOptions: { #{ajops} },
                        callback: function(form, value) 
                          { return 'authenticity_token=#{form_authenticity_token}&#{objname}[#{prop}]=' + escape(value) },
                        onComplete: function(transport, element) 
                          { element.innerHTML=transport.responseText.evalJSON().#{prop};}"
      tg += ",#{edops}" unless edops.empty?
      tg += "});\n"
      tg += "         </script>\n"

    end
  end

  #Converts a hash into a JSON options list
  # (without the encompasing {}'s or any type of recursion
  #Is there a rails API function that does this? 
  def jsonify hsh
    str = ''
    first = true
    hsh.each do |k,v|
      str += ', ' unless first
      str += "#{k}: "
      str += "'" unless (v.class == Fixnum or v.class == Float)
      str += v.to_s
      str += "'" unless (v.class == Fixnum or v.class == Float)
      first = false
    end
    str
  end

  # Determines which element to replace on the form builder interface, and which 
  # partial to replace it with, based on the state of the element being updated.
  def replacement_elements(element)
    if (element.form_id.blank?)
      replace_element = 'library-admin'
      replace_partial =  'forms/library_admin'
    elsif (element.is_a?(InvestigatorViewElementContainer) || element.ancestors[1].is_a?(InvestigatorViewElementContainer))
      replace_element = 'root-element-list'
      replace_partial =  'forms/elements'
    elsif (element.is_a?(CoreViewElementContainer) || element.ancestors[1].is_a?(CoreViewElementContainer))
      replace_element = 'core-element-list'
      replace_partial =  'forms/core_elements'
    else
      replace_element = 'core-field-element-list'
      replace_partial =  'forms/core_field_elements'
    end
    return replace_element, replace_partial
  end
  
  def current_user_name
    if (User.current_user.last_name.blank? || User.current_user.first_name.blank?)
      User.current_user.user_name
    else
      "#{User.current_user.first_name} #{User.current_user.last_name}"
    end
  end
  
  # http://www.pathf.com/blogs/2008/07/pretty-blocks-in-rails-views/
  def tabbed_content(tabs, focus_tab, &block)
    raise ArgumentError, "Missing block" unless block_given?

    tabs_string = tabs.map{|tab| "'#{tab.first}'"}.join(',')

    concat(
      javascript_tag("var myTabs = new YAHOO.widget.TabView('cmr_tabs'); myTabs.set('activeIndex', #{focus_tab});") +

      content_tag(:span, "[Disable Tabs]", :id => 'disable_tabs', :onClick => "myTabs.removeClass('yui-navset'); myTabs.removeClass('yui-content'); [#{tabs_string}].each(Element.show); Element.hide('disable_tabs'); Element.hide('tabs'); Element.show('enable_tabs');return false;") +
      content_tag(:span, "[Enable Tabs]", :id => 'enable_tabs', :onClick => "myTabs.addClass('yui-navset'); myTabs.addClass('yui-content'); [#{tabs_string},'enable_tabs'].each(Element.hide); Element.show('disable_tabs'); Element.show('tabs'); myTabs.set('activeIndex',0); return false;", :style => 'display: none;') +

      content_tag(:div, :id => "cmr_tabs", :class => "yui-navset") do
        content_tag(:ul, :id => "tabs", :class => "yui-nav") do
          line_items = ""
          tabs.each do |tab|
            line_items += content_tag(:li) do
              link_to(content_tag(:em, tab.last), "##{tab.first}")
            end
          end
          line_items
        end +
        content_tag(:div, :class => "yui-content") do
          capture(&block)
        end
      end)
  end

  def format_date(date, using='%B %d, %Y')
    date.strftime(using) if date
  end

  def cmrs_path_with_defaults
    cmrs_path(User.current_user.event_view_settings || {})
  end 

  def save_buttons(event)
    event_type = event.class.to_s.underscore
    if event.new_record?
      form_id = "new_#{event_type}"
    else
      form_id = "edit_#{event_type}_#{event.id}"
    end

    content_for :enable_save_buttons do
      content = "&nbsp;&nbsp;" + link_to_function("Enable Save Buttons", "toggle_save_buttons('on')", :onmouseout => "UnTip()", :onmouseover => "TagToTip('save_button_help', FADEOUT, 500, FADEIN, 500)")
      content += "<div id='save_button_help' style='display: none;'>Click here to enable the save buttons if they are grayed out when they shouldn't be.</div>"
    end
    # The display: inline style is to get IE to render the two buttons side by side.
    out =  button_to_function("Save & Continue", "post_and_return('#{form_id}')", :id => "save_and_continue_btn", :onclick => "toggle_save_buttons('off');")
    out += button_to_function("Save & Exit", "post_and_exit('#{form_id}')", :id => "save_and_exit_btn", :onclick => "toggle_save_buttons('off');")
  end

  # Extremely simplistic auto_complete helper, 'cause the default one don't worky.  Makes a lot of assumptions, but what we need for now.
  def trisano_auto_complete(form, method_name, label, tag_options, completion_options)
    method_name = method_name.to_s
    rand_id = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
    tf_id = "#{form.object_name.gsub(/\]\[|\[|\]$/, '_')}#{method_name}_#{rand_id}"
    tag_options.merge!({:id => tf_id})
    completion_options.merge!(:method => :get, :indicator => "#{tf_id}_lab_spinner")
    return <<-HTML
      #{auto_complete_stylesheet}
      #{form.label(method_name, label)}
      #{form.text_field(method_name, tag_options)}
      #{image_tag 'redbox_spinner.gif', :id => "#{tf_id}_lab_spinner", :alt => 'Working...', :style => 'display: none;', :size => '16x16'}
      #{content_tag("div", "", :id => "#{tf_id}_auto_complete", :class => "auto_complete")}
      #{auto_complete_field tf_id, completion_options}
    HTML
  end


  # If this is an html request, then the script will be run when the
  # dom finishes loading. If it's an Ajax request, then the script
  # will be sent as is, so that the it can be eval-ed when the browser
  # is ready.
  def on_loaded_or_eval(&block)
    return unless block_given?
    <<-JS
      <script type="text/javascript">
        #{"document.observe('dom:loaded', function() {" unless request.xhr?}
        #{block.call}
        #{"\});" unless request.xhr?}
      </script>
    JS
  end
end
