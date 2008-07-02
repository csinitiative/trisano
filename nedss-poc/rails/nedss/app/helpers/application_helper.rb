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
    p options
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

  #stupid helper helper to convert a hash into a JSON options list
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

  def replacement_elements(element)
    if (element.is_a?(InvestigatorViewElementContainer) || element.ancestors[1].is_a?(InvestigatorViewElementContainer))
      replace_element = 'root-element-list'
      replace_partial =  'forms/elements'
    else
      replace_element = 'core-element-list'
      replace_partial =  'forms/core_elements'
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
  
  def tab_toggler(include_investigation_tab)
    result = ""
    investigation_tab = (include_investigation_tab == true) ?  ", 'investigation_tab'" : ""
    result += "<span id='disable_tabs' onClick=\"myTabs.removeClass('yui-navset'); myTabs.removeClass('yui-content'); ['demographic_tab','clinical_tab','lab_info_tab', 'contacts_tab', 'epi_tab','reporting_tab','administrative_tab'#{investigation_tab}].each(Element.show); Element.hide('disable_tabs'); Element.hide('tabs'); Element.show('enable_tabs');return false;\">[Disable Tabs]</span>"
    result += "<span id='enable_tabs' onClick=\"myTabs.addClass('yui-navset'); myTabs.addClass('yui-content'); ['demographic_tab','clinical_tab','lab_info_tab', 'contacts_tab',  'epi_tab', 'reporting_tab', 'administrative_tab', 'enable_tabs'#{investigation_tab}].each(Element.hide); Element.show('disable_tabs'); Element.show('tabs'); myTabs.set('activeIndex',0); return false;\" style='display: none;'>[Enable Tabs]</span>"
    result
  end

end
