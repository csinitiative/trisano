require File.dirname(__FILE__) + '/spec_helper' 

module NedssHelper
  #Define constants for standard resources
  FORM = "forms"
  
  # Constants for element id prefixes
  VIEW_ID_PREFIX = "view_"
  CORE_VIEW_ID_PREFIX = "core_view_"
  SECTION_ID_PREFIX = "section_"
  GROUP_ID_PREFIX = "group_"
  QUESTION_ID_PREFIX = "question_"
  FOLLOW_UP_ID_PREFIX = "follow_up_"
    
  INVESTIGATOR_ANSWER_ID_PREFIX = "investigator_answer_"
  
  #Use create_cmr to build a CMR from a hash of field names and values (field names are indexes)
  #TODO modify to act directly on database
  #TODO this only works for text fields. It needs to wrok for drop-downs too 
  def create_cmr(browser, value_hash)
    fields = browser.get_all_fields
    value_hash.each_pair do |key, value|
      if fields.index(key) != nil
        browser.type(key, value) 
      else
        browser.select(key,"label=" + value)
      end
    end
    browser.click('event_submit')
    browser.wait_for_page_to_load($load_time)
  end
  
  #Use click_core_tab to change tabs in CMR views
  def click_core_tab(browser, tab_name)
    case tab_name
    when "Demographics"
      browser.click('//li[1]/a/em')
    when "Clinical"
      browser.click('//li[2]/a/em')
    when "Laboratory"
      browser.click('//li[3]/a/em')
    when "Contacts"
      browser.click('//li[4]/a/em')
    when "Epidemiological"
      browser.click('//li[5]/a/em')
    when "Reporting"
      browser.click('//li[6]/a/em')
    when "Administrative"
      browser.click('//li[7]/a/em')
    when "Investigation"
      browser.click('//li[8]/a/em')
    else
      puts("TAB NOT FOUND: " + tab_name)
    end
  end
  
  #Use click_link_by_order to click the Nth element in a list of links of the same element type
  def click_link_by_order(browser, element_id_prefix, order)
    links = browser.get_all_links
    links.delete_if{|link| link.index(element_id_prefix) == nil}
    browser.click(links[order])
  end
  
  def type_field_by_order(browser, element_id_prefix, order, value)
    fields = browser.get_all_fields
    fields.delete_if{|field| field.index(element_id_prefix) == nil}
    browser.type(field[order], value)
  end
  
  # Use click_resource methods from any standard resource index page
  def click_resource_edit(browser, resource, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/nedss/" + resource + "/" + id.to_s + "/edit')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_resource_show(browser, resource, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/nedss/" + resource + "/" + id.to_s + "')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_build_form(browser, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/nedss/forms/builder/" + id.to_s + "')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def create_basic_investigatable_cmr(browser, last_name, disease_label, jurisdiction_label)
    browser.click "link=New CMR"
    browser.wait_for_page_to_load($load_time)
    browser.type "event_active_patient__active_primary_entity__person_last_name", last_name
    click_core_tab(browser, "Clinical")
    browser.select "event_disease_disease_id", "label=#{disease_label}"
    click_core_tab(browser, "Administrative")
    browser.select "event_active_jurisdiction_secondary_entity_id", "label=#{jurisdiction_label}"
    browser.select "event_event_status_id", "label=Under Investigation"
    browser.click "event_submit"
    browser.wait_for_page_to_load($load_time)
  end
  
  def answer_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_answer_id(browser, question_text)
    browser.type("#{INVESTIGATOR_ANSWER_ID_PREFIX}#{answer_id}", answer)
  end
  
  def create_new_form_and_go_to_builder(browser, form_name, disease_label, jurisdiction_label)
    browser.open "/nedss/cmrs"
    browser.click "link=Forms"
    browser.wait_for_page_to_load($load_time)
    browser.click "link=New form"
    browser.wait_for_page_to_load($load_time)
    browser.type "form_name", form_name
    browser.select "form_disease_id", "label=#{disease_label}"
    browser.select "form_jurisdiction_id", "label=#{jurisdiction_label}"
    browser.click "form_submit"
    browser.wait_for_page_to_load($load_time)
    browser.click "link=Form Builder"
    browser.wait_for_page_to_load($load_time)
  end
  
  # Takes the name of the tab to which the question should be added and the question's attributes.
  def add_question_to_view(browser, element_name, question_text, data_type_label, is_active=true)
    add_question_to_element(browser, element_name, VIEW_ID_PREFIX, question_text, data_type_label, is_active)
  end
  
  # Takes the name of the section to which the question should be added and the question's attributes.
  def add_question_to_section(browser, element_name, question_text, data_type_label, is_active=true)
    add_question_to_element(browser, element_name, SECTION_ID_PREFIX, question_text, data_type_label, is_active)
  end
  
  # Takes the name of the follow-up container to which the question should be added and the question's attributes.
  def add_question_to_follow_up(browser, element_name, question_text, data_type_label, is_active=true)
    add_question_to_element(browser, element_name, FOLLOW_UP_ID_PREFIX, question_text, data_type_label, is_active)
  end
  
  # Takes the question text of the question to which the follow-up should be added and the follow-up's attributes
  def add_follow_up_to_question(browser, question_text, condition)
    add_follow_up_to_element(browser, question_text, QUESTION_ID_PREFIX, condition)
  end
  
  # Takes the name of the view to which the follow-up should be added and the follow-up's attributes.
  def add_core_follow_up_to_view(browser, element_name, condition, core_label)
    add_follow_up_to_element(browser, element_name, VIEW_ID_PREFIX, condition, core_label)
  end
  
  def publish_form(browser)
    browser.click '//input[@value="Publish"]'
    browser.wait_for_page_to_load($load_time)
  end
  
  #TODO
  def click_question(browser, question, action)
    case action
    when "edit"
      q_id = get_form_element_id(browser, question, QUESTION_ID_PREFIX)
      browser.click("edit-question-" + q_id.to_s)
      sleep 2 #TODO replacing the wait below until it works properly
      #wait_for_element_present("edit-question-form")
    when "delete"
      q_id = get_form_element_id(browser, question, QUESTION_ID_PREFIX)
      browser.click("delete-question-" + q_id.to_s)
      sleep 2 #TODO - should probably replace this with the element name, if there is one
    when "Add value set"
      #TODO
    else #TODO - this is an error
    end
  end
  
  #TODO 
  def click_add_core_data_element_to_section(browser, section)
    
  end
  
  #TODO
  def click_core_data_element(browser, element, action)
  
  end
  
  #Get a unique name with the input number of words in it
  def get_unique_name(words)
    if words > 1000
      words = 1000
    else 
      if words < 1
        words = 1
      end
    end
    ret = get_random_word
    for i in 2..words
      ret = ret + " " + get_random_word
    end
    return ret
  end
  
  def num_times_text_appears(browser, text)
    browser.get_body_text.scan(/#{text}/).size
  end

  private
  
  def add_question_to_element(browser, element_name, element_id_prefix, question_text, data_type_label, is_active)
    element_id = get_form_element_id(browser, element_name, element_id_prefix)
    browser.click("add-question-#{element_id}")
    wait_for_element_present("new-question-form", browser)
    browser.type("question_element_question_attributes_question_text", question_text)
    browser.select("question_element_question_attributes_data_type", "label=#{data_type_label}")
    browser.click("question_element_is_active_#{is_active.to_s}")
    browser.click "question_element_submit"    
    wait_for_element_not_present("new-question-form", browser)
  end
  
  def add_follow_up_to_element(browser, element_name, element_id_prefix, condition, core_label=nil)
    element_id = get_form_element_id(browser, element_name, element_id_prefix)
    browser.click("add-follow-up-#{element_id}")
    wait_for_element_present("new-follow-up-form", browser)
    browser.type "follow_up_element_condition", condition
    browser.select "follow_up_element_core_path", "label=#{core_label}" unless core_label.nil?
    browser.click "follow_up_element_submit"
    wait_for_element_not_present("new-follow-up-form", browser)
  end
  
  def get_form_element_id(browser, name, element_id_prefix)
    element_prefix_length = element_id_prefix.size
    html_source = browser.get_html_source
    name_position = html_source.index(name)
    id_start_position = html_source.rindex("#{element_id_prefix}", name_position) + element_prefix_length
    id_end_position = html_source.index("\"", id_start_position)-1
    html_source[id_start_position..id_end_position]
  end
  
  def get_investigator_answer_id(browser, question_text)
    html_source = browser.get_html_source
    question_position = html_source.index(question_text)
    id_start_position = html_source.index(INVESTIGATOR_ANSWER_ID_PREFIX, question_position) + 20
    id_end_position = html_source.index("\"", id_start_position) -1
    html_source[id_start_position..id_end_position]
  end
  
  def get_random_word
    wordlist = ["Lorem","ipsum","dolor","sit","amet","consectetuer","adipiscing","elit","Duis","sodales","dignissim","enim","Nunc","rhoncus","quam","ut","quam","Quisque","vitae","urna","Duis","nec","sapien","Proin","mollis","congue","mauris","Fusce","lobortis","tristique","elit","Phasellus","aliquam","dui","id","placerat","hendrerit","dolor","augue","posuere","tellus","at","ultricies","libero","leo","vel","leo","Nulla","purus","Ut","lacus","felis","tempus","at","egestas","nec","cursus","nec","magna","Ut","fringilla","aliquet","arcu","Vestibulum","ante","ipsum","primis","in","faucibus","orci","luctus","et","ultrices","posuere","cubilia","Curae","Etiam","vestibulum","urna","sit","amet","sem","Nunc","ac","ipsum","In","consectetuer","quam","nec","lectus","Maecenas","magna","Nulla","ut","mi","eu","elit","accumsan","gravida","Praesent","ornare","urna","a","lectus","dapibus","luctus","Integer","interdum","bibendum","neque","Nulla","id","dui","Aenean","tincidunt","dictum","tortor","Proin","sagittis","accumsan","nulla","Etiam","consectetuer","Etiam","eget","nibh","ut","sem","mollis","luctus","Etiam","mi","eros","blandit","in","suscipit","ut","vestibulum","et","velit","Fusce","laoreet","nulla","nec","neque","Nam","non","nulla","ut","justo","ullamcorper","egestas","In","porta","ipsum","nec","neque","Cras","non","metus","id","massa","ultrices","rhoncus","Donec","mattis","odio","sagittis","nunc","Vivamus","vehicula","justo","vitae","tincidunt","posuere","risus","pede","lacinia","dolor","quis","placerat","justo","arcu","ut","tortor","Aliquam","malesuada","lectus","id","condimentum","sollicitudin","arcu","mauris","adipiscing","turpis","a","sollicitudin","erat","metus","vel","magna","Proin","scelerisque","neque","id","urna","lobortis","vulputate","In","porta","pulvinar","urna","Cras","id","nulla","In","dapibus","vestibulum","pede","In","ut","velit","Aliquam","in","turpis","vitae","nunc","hendrerit","ullamcorper","Aliquam","rutrum","erat","sit","amet","velit","Nullam","pharetra","neque","id","pede","Phasellus","suscipit","ornare","mi","Ut","malesuada","consequat","ipsum","Suspendisse","suscipit","aliquam","nisl","Suspendisse","iaculis","magna","eu","ligula","Sed","porttitor","eros","id","euismod","auctor","dolor","lectus","convallis","justo","ut","elementum","magna","magna","congue","nulla","Pellentesque","eget","ipsum","Pellentesque","tempus","leo","id","magna","Cras","mi","dui","pellentesque","in","pellentesque","nec","blandit","nec","odio","Pellentesque","eget","risus","In","venenatis","metus","id","magna","Etiam","blandit","Integer","a","massa","vitae","lacus","dignissim","auctor","Mauris","libero","metus","aliquet","in","rhoncus","sed","volutpat","quis","libero","Nam","urna"]
    wordlist[1 + rand(320)]
  end
  
  def get_resource_id(browser, name)
    html_source = browser.get_html_source
    pos1 = html_source.index(name)
    pos2 = html_source.index("/edit\"", pos1)-1
    pos3 = html_source.rindex("/", pos2)+1
    id = html_source[pos3..pos2]
    return id.to_i
  rescue => err
    return -1
  end
end
