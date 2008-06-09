module FormsHelper
  
  def render_element(element, include_children=true)
    
    case element.class.name
    when "ViewElement"
      render_view(element, include_children)
    when "CoreViewElement"
      render_core_view(element, include_children)
    when "SectionElement"
      render_section(element, include_children)
    when "GroupElement"
      render_group(element, include_children)
    when "QuestionElement"
      render_question(element, include_children)
    when "FollowUpElement"
      render_follow_up_container(element, include_children)
    when "ValueSetElement"
      render_value_set(element, include_children)
    when "ValueElement"
      render_value(element, include_children)
    end

  end
  
  def render_view(element, include_children=true)
    
    li_html_id = get_li_html_id(element.id)
    result = section_preamble(li_html_id, element, 'tab')
    result += "</li>"

    result += add_section_link(element, "tab")
    result += "&nbsp;|&nbsp;"
    result += add_question_link(element, "tab")

    result += "<div id='section-mods-" + element.id.to_s + "'></div>"
    result += "<div id='question-mods-" + element.id.to_s + "'></div>"

    if include_children && element.children?
      result += "<ul id='view_" + element.id.to_s + "_children', style='clear: both'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
      result += sortable_element("view_#{element.id}_children", :constraint => :vertical, :only => "sortable", :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
    end
    
    result
  end
  
  def render_core_view(element, include_children)

    li_html_id = get_li_html_id(element.id)
    result = section_preamble(li_html_id, element, 'tab')
    result += "</li>"
    
    if include_children && element.children?
      result += "<ul id='view_" + element.id.to_s + "_children', :style='clear: both'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
      result += sortable_element("view_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
    end
    
    result += add_section_link(element, "tab")
    result += "&nbsp;|&nbsp;"
    result += add_question_link(element, "tab")
    
    result += "<div id='section-mods-" + element.id.to_s + "'></div>"
    result += "<div id='question-mods-" + element.id.to_s + "'></div>"
  end
  
  def render_section(element, include_children=true)

    li_html_id = get_li_html_id(element.id)
    result = section_preamble(li_html_id, element, 'section')
    result += "</li>"

    result += add_question_link(element, "section") if (include_children)
    # Uncomment (and make current) when core data back in scope
    # result += add_core_data_link(element) if (include_children)

    result += "<div id='question-mods-" + element.id.to_s + "'></div>"

    if include_children && element.children?
      result += "<ul id='section_" + element.id.to_s + "_children', style='clear: both'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
      result += sortable_element("section_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
    end
    
    result
  end

  def render_group(element, include_children=true)

    li_html_id = get_li_html_id(element.id)
    result = section_preamble(li_html_id, element, "group")
    result += "</li>"

    if include_children && element.children?
      result += "<ul id='section_" + element.id.to_s + "_children', style='clear: both'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
      result += sortable_element("section_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
    end
    
    result
  end
 
  def render_question(element, include_children=true)
    
    question = element.question
    question_id = "question_#{element.id}"
    
    result = "<li class='sortable' id='#{question_id}', style='clear: both;'>"

    css_class = element.is_active? ? "question" : "inactive-question"
    result += "<span class='#{css_class}'>"
    result += "Question: " + question.question_text
    result += "&nbsp;&nbsp;<small>(" + question.data_type_before_type_cast.humanize + ")</small>"
    result += "&nbsp;<i>(Inactive)</i>" unless element.is_active
    result += "</span>"
    result += "</li>"
    
    result += "&nbsp;" + edit_question_link(element) + "&nbsp;|&nbsp;" + delete_question_link(element) + "&nbsp;|&nbsp;" + add_follow_up_container_link(element) + "&nbsp;|&nbsp;" + add_to_library_link(element) if (include_children)
    
    result += "&nbsp;|&nbsp;" + add_value_set_link(element) if include_children && element.is_multi_valued_and_empty?

    result += "<div id='question-mods-" + element.id.to_s + "'></div>"
    result += "<div id='value-set-mods-" + element.id.to_s + "'></div>"

    if include_children && element.children?
      result += "<ul id='question_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result

    # result += draggable_element question_id, :revert => true
  end

  def render_follow_up_container(element, include_children=true)
    
    result = "<li class='follow-up-item' id='#{element.id}'>Follow up for: '#{element.condition}'"
    
    if include_children && element.children?
      result += "<ul id='follow_up_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
      result += sortable_element("follow_up_#{element.id}_children", :constraint => :vertical, :url => { :controller => 'forms', :action => 'order_section_children', :id => element.id})
    end
    
    result += add_question_link(element, "follow up container") if (include_children)
    
    result += "<div id='question-mods-" + element.id.to_s + "'></div>"
    
    result += "</li>"
    
    result
  end
  
  def render_value_set(element, include_children=true)
    result =  "<li id='value_set_" + element.id.to_s + "'>Value Set: "
    result += element.name
    
    if include_children && element.children?
      result += "&nbsp;" + edit_value_set_link(element)
      result += "<div id='value-set-mods-" + element.id.to_s + "'></div>"

      result += "<ul id='value_set_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result += "</li>"
  end
  
  def render_value(element, include_children=true)
    result =  "<li id='value_" + element.id.to_s + "'>"
    result += "<span class='inactive-value'>" unless element.is_active
    result += element.name
    result += "&nbsp;<i>(Inactive)</i></span>" unless element.is_active
    result += "</li>"
  end
  
  private

  def add_section_link(element, trailing_text)
    "<small><a href='#' onclick=\"new Ajax.Request('../../section_elements/new?form_element_id=" + 
      element.id.to_s + "', {asynchronous:true, evalScripts:true}); return false;\" id='add-section-" + 
      element.id.to_s + "' class='add-section' name='add-section'>Add section to #{trailing_text}</a></small>"
  end

  def add_question_link(element, trailing_text)
    "<small><a href='#' onclick=\"new Ajax.Request('../../question_elements/new?form_element_id=" + 
      element.id.to_s + "&core_data=false" + "', {asynchronous:true, evalScripts:true}); return false;\" id='add-question-" + 
      element.id.to_s + "' class='add-question' name='add-question'>Add question to #{trailing_text}</a></small>"
  end
  
  def edit_question_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../question_elements/" + element.id.to_s + 
      "/edit', {asynchronous:true, evalScripts:true, method:'get'}); return false;\" class='edit-question' id='edit-question-" + element.id.to_s + 
      "'>Edit</a></small>"
  end
  
  def delete_question_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../form_elements/" + element.id.to_s + 
      "', {asynchronous:true, evalScripts:true, method:'delete'}); return false;\" class='delete-question' id='delete-question-" + element.id.to_s + "'>Delete</a></small>"
  end
  
  def add_follow_up_container_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../follow_up_elements/new?form_element_id=" + 
      element.id.to_s + "', {asynchronous:true, evalScripts:true}); return false;\" id='add-follow-up-" + 
      element.id.to_s + "' class='add-follow-up' name='add-follow-up'>Add follow up container</a></small>"
  end

  def add_to_library_link(element)
    "<small>" + link_to_remote("Copy to library", :url => {:controller => "group_elements", :action => "new", :form_element_id => element.id}) +"</small>"
  end

  def add_value_set_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../value_set_elements/new?form_element_id=" + 
      element.id.to_s + "&form_id=" + element.form_id.to_s  + "', {asynchronous:true, evalScripts:true}); return false;\">Add value set</a></small>"
  end

  def edit_value_set_link(element)
    "<small><a href='#' onclick=\"new Ajax.Request('../../value_set_elements/" + element.id.to_s + "/edit', {method:'get', asynchronous:true, evalScripts:true}); return false;\">Edit value set</a></small>"
  end

  def add_core_data_link(element)
    "<br /><small><a href='#' onclick=\"new Ajax.Request('../../question_elements/new?form_element_id=" + 
      element.id.to_s + "&core_data=true" + "', {asynchronous:true, evalScripts:true}); return false;\">Add a core data element</a></small>"
  end
  
  def section_preamble(html_id, element, type)
# Enable and fix url arguments when time for in place editing
#    editable_content = editable_content_tag(:span, element, 'name', true, {:url => url_for(:controller => "view_elements", :action => "update", :form_id => element.form_id)})
    editable_content= element.name

    "<li id='#{html_id}', class='fb-#{type}', style='clear: both'><b>#{editable_content}</b>"
  end
  
  def get_li_html_id(id)
    "section_#{id}"
  end
end
