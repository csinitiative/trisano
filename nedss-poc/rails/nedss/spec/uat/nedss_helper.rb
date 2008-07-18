require File.dirname(__FILE__) + '/spec_helper' 

module NedssHelper
  #Define constants for standard resources
  FORM = "forms"
  
  # Constants for the tab names
  DEMOGRAPHICS = "Demographics"
  CLINICAL = "Clinical"
  LABORATORY = "Laboratory"
  CONTACTS = "Contacts"
  EPI = "Epidemiological"
  REPORTING = "Reporting"
  ADMIN = "Administrative"
  INVESTIGATION = "Investigation"
  
  # Constants for element id prefixes
  VIEW_ID_PREFIX = "view_"
  CORE_VIEW_ID_PREFIX = "core_view_"
  SECTION_ID_PREFIX = "section_"
  GROUP_ID_PREFIX = "group_"
  QUESTION_ID_PREFIX = "question_"
  FOLLOW_UP_ID_PREFIX = "follow_up_"
    
  INVESTIGATOR_ANSWER_ID_PREFIX = "investigator_answer_"
  
  TAB_ELEMENT_IDS_BY_NAME = {
    DEMOGRAPHICS => "demographic_tab",
    CLINICAL => "clinical_tab",
    LABORATORY => "lab_info_tab",
    CONTACTS => "contacts_tab",
    EPI => "epi_tab",
    REPORTING => "reporting_tab",
    ADMIN => "administrative_tab"
  }

  #  Use set_fields after you navigate to any location by passing in a hash of 
  #  fields and values and this method will set them all. It will work for 
  #  updating existing items or creating new ones. cmr_helper_example shows how 
  #  to create a complete CMR with the helper. The hash created in this example 
  #  could be helpful for other tests. Note that this method does not submit 
  #  for you. 
  def set_fields(browser, value_hash)
    fields = browser.get_all_fields
    puts fields
    value_hash.each_pair do |key, value|
      if fields.index(key) != nil
        browser.type(key, value) 
      else
        begin
          browser.select(key,"label=" + value)
        rescue StandardError => err
          puts err
          if err == "Specified element is not a Select (has no options)"
            #This is usually because the element is the name of a auto-complete field
            browser.type(key, value)
          else
            puts("WARNING: Field " + key + " not found. Value not set.")
          end
        end
      end
    end
  end
  
  #TODO Check for link first and navigate to home page if not found, then click new
  def click_new_cmr(browser)
    browser.click("link=NEW CMR")
  end
  
  # Use get_full_cmr to create a cmr with every field filled in (excludes repeating elements)
  # It uses random words for text fields
  def create_cmr_from_hash(browser, cmr_hash)
    click_new_cmr(browser)
    browser.wait_for_page_to_load($load_time)
    set_fields(browser,cmr_hash)
    browser.click('event_submit')
    browser.wait_for_page_to_load($load_time)
  end
  
  # Use get_full_cmr to create a cmr with only the last name filled in
  # It uses random words for the last name field
  def get_nil_cmr()
    
  end
  
  #Use click_core_tab to change tabs in CMR views
  def click_core_tab(browser, tab_name)
    case tab_name
    when DEMOGRAPHICS
      browser.click('//li[1]/a/em')
    when CLINICAL
      browser.click('//li[2]/a/em')
    when LABORATORY
      browser.click('//li[3]/a/em')
    when CONTACTS
      browser.click('//li[4]/a/em')
    when EPI
      browser.click('//li[5]/a/em')
    when REPORTING
      browser.click('//li[6]/a/em')
    when ADMIN
      browser.click('//li[7]/a/em')
    when INVESTIGATION
      browser.click('//li[8]/a/em')
    else
      puts("TAB NOT FOUND: " + tab_name)
    end
  end
  
  def click_nav_new_cmr(browser)
    browser.click 'link=NEW CMR'
    browser.wait_for_page_to_load($load_time)
  end
  
  def click_nav_cmrs(browser)
    browser.click 'link=CMRS'
    browser.wait_for_page_to_load($load_time)
  end
  
  def click_nav_search(browser)
    browser.click 'link=SEARCH'
    browser.wait_for_page_to_load($load_time)
  end
  
  def click_nav_forms(browser)
    browser.click 'link=FORMS'
    browser.wait_for_page_to_load($load_time)
  end
  
  def click_nav_admin(browser)
    browser.click 'link=ADMIN'
    browser.wait_for_page_to_load($load_time)
  end
  
  def edit_cmr(browser)
    browser.click "edit_cmr_link"
    browser.wait_for_page_to_load($load_time)
  end
  
  def save_cmr(browser)
    browser.click "event_submit"
    browser.wait_for_page_to_load($load_time)
  end
  
  def navigate_to_people_search(browser)
    click_nav_search(browser)
    @browser.click('link=People Search')
    @browser.wait_for_page_to_load($load_time)
  end
  
  def navigate_to_cmr_search(browser)
    click_nav_search(browser)
    @browser.click('link=CMR Search')
    @browser.wait_for_page_to_load($load_time)
  end
  
  #Use click_link_by_order to click the Nth element in a list of links of the same element type
  def click_link_by_order(browser, element_id_prefix, order)
    links = browser.get_all_links
    links.delete_if{|link| link.index(element_id_prefix) == nil}
    browser.click(links[order-1])
  end
  
  def type_field_by_order(browser, element_id_prefix, order, value)
    fields = browser.get_all_fields
    fields.delete_if{|field| field.index(element_id_prefix) == nil}
    browser.type(fields[order], value)
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
    click_nav_new_cmr(browser)
    browser.type "event_active_patient__active_primary_entity__person_last_name", last_name
    click_core_tab(browser, CLINICAL)
    browser.select "event_disease_disease_id", "label=#{disease_label}"
    click_core_tab(browser, ADMIN)
    browser.select "event_active_jurisdiction_secondary_entity_id", "label=#{jurisdiction_label}"
    browser.select "event_event_status_id", "label=Under Investigation"
    save_cmr(browser)
  end
  
  def answer_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_answer_id(browser, question_text)
    browser.type("#{INVESTIGATOR_ANSWER_ID_PREFIX}#{answer_id}", answer)
  end
  
  def create_new_form_and_go_to_builder(browser, form_name, disease_label, jurisdiction_label)
    browser.open "/nedss/cmrs"
    browser.click "link=FORMS"
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
  
  def switch_user(browser, user_id)
    browser.select("user_id", "label=#{user_id}")
    sleep(2)  
    browser.refresh
    browser.wait_for_page_to_load "30000"
  end

  # Takes the name of the tab to which the question should be added and the question's attributes.  
  def add_question_to_view(browser, element_name, question_attributes = {})
    add_question_to_element(browser, element_name, VIEW_ID_PREFIX, question_attributes)
  end
  
  # Takes the name of the section to which the question should be added and the question's attributes.
  def add_question_to_section(browser, element_name, question_attributes = {})
    add_question_to_element(browser, element_name, SECTION_ID_PREFIX, question_attributes)
  end
  
  # Takes the name of the follow-up container to which the question should be added and the question's attributes.
  def add_question_to_follow_up(browser, element_name, question_attributes = {})
    add_question_to_element(browser, element_name, FOLLOW_UP_ID_PREFIX, question_attributes)
  end
  
  # Takes the question text of the question to which the follow-up should be added and the follow-up's attributes
  def add_follow_up_to_question(browser, question_text, condition)
    add_follow_up_to_element(browser, question_text, QUESTION_ID_PREFIX, condition)
  end
  
  # Takes the name of the view to which the follow-up should be added and the follow-up's attributes.
  def add_core_follow_up_to_view(browser, element_name, condition, core_label)
    add_follow_up_to_element(browser, element_name, VIEW_ID_PREFIX, condition, core_label)
  end
  
  def add_core_tab_configuration(browser, core_view_name)
    browser.click("link=Add a core tab configuration")
    wait_for_element_present("new-core-view-form", browser)
    browser.select("core_view_element_name", "label=#{core_view_name}")
    browser.click("core_view_element_submit")
    wait_for_element_not_present("new-core-view-form", browser)
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
  
  def assert_tab_contains_question(browser, tab_name, question_text)
    html_source = browser.get_html_source
    question_position = html_source.index(question_text)
    id_start_position = html_source.index(INVESTIGATOR_ANSWER_ID_PREFIX, question_position)
    id_end_position = html_source.index("\"", id_start_position) -1
    answer_input_element_id = html_source[id_start_position..id_end_position]
    tab_element_id = TAB_ELEMENT_IDS_BY_NAME[tab_name]
    assert_contains(browser, tab_element_id, answer_input_element_id)
  end
  
  def get_record_number(browser)
    html_source = browser.get_html_source
    text_position = html_source.index("Record number:")
    record_number_start_position = html_source.index(Time.now.year.to_s, text_position)
    record_number_end_position = html_source.index("</td>", record_number_start_position) -1
    html_source[record_number_start_position..record_number_end_position]
  end

  def get_full_cmr_hash()
    @cmr_fields = {
              # Patient fields
              "event_active_patient__active_primary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__person_middle_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__address_street_number" => "123",
              "event_active_patient__active_primary_entity__address_street_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__address_unit_number" => "2",
              "event_active_patient__active_primary_entity__address_city" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__address_postal_code" => "84601",
              "event_active_patient__active_primary_entity__person_birth_date" => "1/1/1974",
              "event_active_patient__active_primary_entity__person_approximate_age_no_birthday" => "22",
              "event_active_patient__active_primary_entity__person_date_of_death" => "1/1/1974",
              "event_active_patient__active_primary_entity__telephone_area_code" => "801",
              "event_active_patient__active_primary_entity__telephone_phone_number" => "555-7894",
              "event_active_patient__active_primary_entity__telephone_extension" => "147",
              "event_active_patient__active_primary_entity__person_birth_gender_id" => "Female",
              "event_active_patient__active_primary_entity__person_ethnicity_id" => "Not Hispanic or Latino",
              "event_active_patient__active_primary_entity__person_primary_language_id" => "Hmong",
              "event_active_patient__active_primary_entity_race_ids" => "Asian",
              "event_active_patient__active_primary_entity__address_county_id" => "Beaver",
              "event_active_patient__active_primary_entity__address_state_id" => "Utah",
             #Disease fields
              "event_disease_disease_onset_date" => "1/1/1974",
              "event_disease_date_diagnosed" => "1/1/1974",
              "event_disease_disease_id" => "Amebiasis",
              #Status fields
              "event_disease_died_id" => "Yes",
              "event_imported_from_id" => "Utah",
              #Hospital fields
              "event_new_hospital_attributes__admission_date" => "1/1/1974",
              "event_new_hospital_attributes__discharge_date" => "1/1/1974",
              "event_new_hospital_attributes__secondary_entity_id" => "Ashley Regional Medical Center",
              "event_disease_hospitalized_id" => "Yes",
              #Diagnosis field
              "event_new_diagnostic_attributes__secondary_entity_id" => "Alta View Hospital",
              #Treatment fields
              "event_active_patient__participations_treatment_treatment_given_yn_id" => "Yes",
              "event_active_patient__participations_treatment_treatment" => NedssHelper.get_unique_name(1),
              #Clinician fields
              "event_clinician__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__person_middle_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__address_street_number" => "456",
              "event_clinician__active_secondary_entity__address_street_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__address_unit_number" => "5141",
              "event_clinician__active_secondary_entity__address_city" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__address_postal_code" => "84602",
              "event_clinician__active_secondary_entity__person_birth_date" => "1/1/1974",
              "event_clinician__active_secondary_entity__person_approximate_age_no_birthday" => "55",
              "event_clinician__active_secondary_entity__person_date_of_death" => "1/1/1974",
              "event_clinician__active_secondary_entity__telephone_area_code" => "501",
              "event_clinician__active_secondary_entity__telephone_phone_number" => "555-1645",
              "event_clinician__active_secondary_entity__telephone_extension" => "1645",
              "event_clinician__active_secondary_entity__person_birth_gender_id" => "Female",
              "event_clinician__active_secondary_entity__person_ethnicity_id" => "Hispanic or Latino",
              "event_clinician__active_secondary_entity_race_ids" => "American Indian",
              "event_clinician__active_secondary_entity__person_primary_language_id" => "Japanese",
              #lab result fields
              "event[new_lab_attributes][][name]" => NedssHelper.get_unique_name(2),
              "event_new_lab_attributes__specimen_source_id" => "Blood",
              "event_new_lab_attributes__tested_at_uphl_yn_id" => "Yes",
              "event_new_lab_attributes__lab_result_text" => NedssHelper.get_unique_name(1),
              "event_new_lab_attributes__collection_date" => "1/1/1974",
              "event_new_lab_attributes__lab_test_date" => "1/1/1974",
              #contact fields
              "event_contact__active_secondary_entity__address_state_id" => "Alaska",
              "event_contact__active_secondary_entity__address_county_id" => "Davis",
              "event_contact__active_secondary_entity__person_birth_gender_id" => "Female",
              "event_contact__active_secondary_entity__person_ethnicity_id" => "Not Hispanic or Latino",
              "event_contact__active_secondary_entity_race_ids" => "American Indian",
              "event_contact__active_secondary_entity__person_primary_language_id" => "Italian",
              "event_contact__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__person_middle_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__address_street_number" => "7845",
              "event_contact__active_secondary_entity__address_street_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__address_unit_number" => "7788",
              "event_contact__active_secondary_entity__address_city" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__address_postal_code" => "87484",
              "event_contact__active_secondary_entity__person_birth_date" => "1/1/1974",
              "event_contact__active_secondary_entity__person_approximate_age_no_birthday" => "64",
              "event_contact__active_secondary_entity__person_date_of_death" => "1/1/1974",
              "event_contact__active_secondary_entity__telephone_area_code" => "840",
              "event_contact__active_secondary_entity__telephone_phone_number" => "555-7457",
              "event_contact__active_secondary_entity__telephone_extension" => "4557"}#,
=begin               #epidemiological fields
              "event_active_patient__participations_risk_factor_food_handler_id" => "Yes",
              "event_active_patient__participations_risk_factor_healthcare_worker_id" => "Yes",
              "event_active_patient__participations_risk_factor_group_living_id" => "Yes",
              "event_active_patient__participations_risk_factor_day_care_association_id" => "Yes",
              "event_active_patient__participations_risk_factor_pregnant_id" => "Yes",
              "event_active_patient__participations_risk_factor_pregnancy_due_date" => "1/1/1974",
              "event_active_patient__participations_risk_factor_risk_factors" => NedssHelper.get_unique_name(3),
              #Not sure why this doesn't work. For some reason rspec thinks this is a select, but it's a type...
              #"event_active_patient__participations_risk_factor_risk_factors_notes" => NedssHelper.get_unique_name(30),              
              #reporting info fields
              "event_active_reporter__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_active_reporter__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_active_reporter__active_secondary_entity__telephone_area_code" => "901",
              "event_active_reporter__active_secondary_entity__telephone_phone_number" => "555-1452",
              "event_active_reporter__active_secondary_entity__telephone_extension" => "4777",
              "event_results_reported_to_clinician_date" => "1/1/1974",
              "model_auto_completer_tf" => NedssHelper.get_unique_name(2), #This is the reporting agency field...
              #Administrative fields
              "event_event_case_status_id" => "Confirmed",
              "event_outbreak_associated_id" => "Yes",
              #"event_active_jurisdiction_secondary_entity_id" => "Out of State",
              "event_event_status_id" => "Investigation Complete",
              "event_event_onset_date" => "1/1/1974",
              "event_outbreak_name" => NedssHelper.get_unique_name(1),
              "event_investigation_started_date" => "1/1/1974",
              "event_investigation_completed_LHD_date" => "1/1/1974",
              "event_event_name" => NedssHelper.get_unique_name(1),
              "event_first_reported_PH_date" => "1/1/1974",
              "event_review_completed_UDOH_date" => "1/1/1974"             
=end             #}
    return(@cmr_fields)
  end
  
  private
  
  def assert_contains(browser, container_element, element)
    begin
      result = browser.get_eval("window.document.getElementById(\"#{element}\").descendantOf(\"#{container_element}\")")
    rescue
      result = false
    end
    
    return (result == "true") ? true : false
  end
  
  def add_question_to_element(browser, element_name, element_id_prefix, question_attributes)
    element_id = get_form_element_id(browser, element_name, element_id_prefix)
    browser.click("add-question-#{element_id}")
    wait_for_element_present("new-question-form", browser)
    browser.type("question_element_question_attributes_question_text", question_attributes[:question_text])
    browser.select("question_element_question_attributes_data_type", "label=#{question_attributes[:data_type]}")
    browser.click("question_element_is_active_#{question_attributes[:is_active].to_s}") if question_attributes.include? :is_active
    browser.type("question_element_question_attributes_short_name", question_attributes[:short_name])  if question_attributes.include? :short_name
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
