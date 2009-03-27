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

require File.dirname(__FILE__) + '/spec_helper'
require 'yaml'

module TrisanoHelper
  #Define constants for standard resources
  FORM = "forms"
  
  # Constants for the tab names
  DEMOGRAPHICS = "Demographics"
  CLINICAL = "Clinical"
  LABORATORY = "Laboratory"
  CONTACTS = "Contacts"
  ENCOUNTERS = "Encounters"
  EPI = "Epidemiological"
  REPORTING = "Reporting"
  INVESTIGATION = "Investigation"
  NOTES = "Notes"
  ADMIN = "Administrative"
  
  # Tabs for place events
  PLACE = "Place"
  
  # Constants for element id prefixes
  VIEW_ID_PREFIX = "view_"
  CORE_VIEW_ID_PREFIX = "core_view_"
  CORE_FIELD_ID_PREFIX = "core_field_"
  BEFORE_CORE_FIELD_ID_PREFIX = "before_core_field_"
  AFTER_CORE_FIELD_ID_PREFIX = "after_core_field_"
  SECTION_ID_PREFIX = "section_"
  GROUP_ID_PREFIX = "group_"
  QUESTION_ID_PREFIX = "question_"
  FOLLOW_UP_ID_PREFIX = "follow_up_"
  VALUE_SET_ID_PREFIX = "value_set_"
    
  INVESTIGATOR_QUESTION_ID_PREFIX = "question_investigate_"
  INVESTIGATOR_ANSWER_ID_PREFIX = "investigator_answer_"
  
  TAB_ELEMENT_IDS_BY_NAME = {
    DEMOGRAPHICS => "demographic_tab",
    CLINICAL => "clinical_tab",
    LABORATORY => "lab_info_tab",
    CONTACTS => "contacts_tab",
    ENCOUNTERS => "encounters_tab",
    EPI => "epi_tab",
    REPORTING => "reporting_tab",
    NOTES => 'notes_tab',
    ADMIN => "administrative_tab",
    PLACE => "place_tab"
  }

  #  Use set_fields after you navigate to any location by passing in a hash of 
  #  fields and values and this method will set them all. It will work for 
  #  updating existing items or creating new ones. cmr_helper_example shows how 
  #  to create a complete CMR with the helper. The hash created in this example 
  #  could be helpful for other tests. Note that this method does not submit 
  #  for you. 
  def set_fields(browser, value_hash)
    fields = browser.get_all_fields
    
    value_hash.each_pair do |key, value|
      if fields.index(key) != nil
        browser.type(key, value) 
      else
        begin
          browser.select(key,"label=" + value)
        rescue StandardError => err
          #TODO - Make this work for auto-complete fields by using the name instead of the ID in a type command
          #The problem with using the name is that it won't show up as a field in get_all_fields, and it won't be selectable
          #I'm trying to do something in the rescue block to detect the error from trying to select it.
          #          if err == "Specified element is not a Select (has no options)"
          #This is usually because the element is the name of a auto-complete field
          #            browser.type(key, value)
          #          else
          puts("WARNING: Field " + key + " not found. Value not set.")
          #          end
        end
      end
    end
  end
  
  # Use get_full_cmr to create a cmr with every field filled in (excludes repeating elements)
  # It uses random words for text fields
  def create_cmr_from_hash(browser, cmr_hash)
    click_nav_new_cmr(browser)
    browser.wait_for_page_to_load($load_time)
    set_fields(browser,cmr_hash)
    browser.click('morbidity_event_submit')
    browser.wait_for_page_to_load($load_time)
    return save_cmr(browser)
  end
  
  # Use get_full_cmr to create a cmr with only the last name filled in
  # It uses random words for the last name field
  def get_nil_cmr()
    
  end

  def current_user(browser = @browser)
    browser.get_selected_label("user_id")
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
    when ENCOUNTERS
      browser.click('//li[5]/a/em')
    when EPI
      browser.click('//li[6]/a/em')
    when REPORTING
      browser.click('//li[7]/a/em')
    when INVESTIGATION
      browser.click('//li[8]/a/em')
    when NOTES
      browser.click('//li[9]/a/em')
    when ADMIN
      browser.click('//li[10]/a/em')
    when PLACE
      browser.click('//li[1]/a/em')
    else
      puts("TAB NOT FOUND: " + tab_name)
    end
  end

  def get_random_disease()
    wordlist = ["African Tick Bite Fever","Amebiasis","Anaplasma phagocytophilum","Anthrax","Aseptic meningitis","Bacterial meningitis, other","Botulism, foodborne","Botulism, infant","Botulism, other unspecified","Botulism, wound","Brucellosis","Cache Valley virus neuroinvasive disease","Cache Valley virus non-neuroinvasive disease","California serogroup virus neuroinvasive disease","California serogroup virus non-neuroinvasive disease","Campylobacteriosis","Chancroid","Chlamydia trachomatis genital infection","Cholera (toxigenic Vibrio cholerae O1 or O139)","Coccidioidomycosis","Cryptosporidiosis","Cyclosporiasis","Dengue","Dengue hemorrhagic fever","Diphtheria","Eastern equine encephalitis virus neuroinvasive disease","Eastern equine encephalitis virus non-neuroinvasive disease","Ehrlichia chaffeensis","Ehrlichia ewingii","Ehrlichiosis/Anaplasmosis, undetermined","Encephalitis, primary","Flu activity code (Influenza)","Giardiasis","Gonorrhea","Granuloma inguinale (GI)","Haemophilus influenzae, invasive disease","Hansen disease (Leprosy)","Hantavirus infection","Hantavirus pulmonary syndrome","Hemolytic uremic syndrome postdiarrheal","Hepatitis A, acute","Hepatitis B virus infection, chronic","Hepatitis B, acute","Hepatitis B, virus infection perinatal","Hepatitis C virus infection, past or present","Hepatitis C, acute","Hepatitis Delta co- or super-infection, acute (Hepatitis D)","Hepatitis E, acute","Hepatitis, viral unspecified","Human T-Lymphotropic virus type I infection (HTLV-I)","Human T-Lymphotropic virus type II infection (HTLV-II)","Influenza, human isolates","Influenza-associated mortality","Japanese encephalitis virus neuroinvasive disease","Japanese encephalitis virus non-neuroinvasive disease","Lead poisoning","Legionellosis","Listeriosis","Lyme disease","Lymphogranuloma venereum (LGV)","Malaria","Measles (rubeola), total","Meningococcal disease (Neisseria meningitidis)","Methicillin- or oxicillin- resistant Staphylococcus aureus coagulase-positive (MRSA a.k.a. ORSA)","Monkeypox","Mumps","Neurosyphilis","Novel influenza A virus infections","Pelvic Inflammatory Disease (PID), Unknown Etiology","Pertussis","Plague","Poliomyelitis, paralytic","Poliovirus infection, nonparalytic","Powassan virus neuroinvasive disease","Powassan virus non-neuroinvasive disease","Psittacosis (Ornithosis)","Q fever, acute","Q fever, chronic","Rabies, animal","Rabies, human","Rocky Mountain spotted fever","Rubella","Rubella, congenital syndrome","Salmonellosis","Severe Acute Respiratory Syndrome (SARS)-associated Coronavirus disease (SARS-CoV)","Shiga toxin-producing Escherichia coli (STEC)","Shigellosis","Smallpox","St. Louis encephalitis virus neuroinvasive disease","St. Louis encephalitis virus non-neuroinvasive disease","Streptococcal disease, invasive, Group A","Streptococcal disease, invasive, Group B","Streptococcal disease, other, invasive, beta-hemolytic (non-group A and non-group B)","Streptococcal toxic-shock syndrome","Streptococcus pneumoniae invasive, drug-resistant (DRSP)","Streptococcus pneumoniae, invasive disease","Syphilis, congenital","Syphilis, early latent","Syphilis, late latent","Syphilis, late with clinical manifestations other than neurosyphilis","Syphilis, primary","Syphilis, secondary","Syphilis, unknown latent","Tetanus","Toxic-shock syndrome (staphylococcal)","Trichinellosis","Tuberculosis","Tularemia","Typhoid fever (caused by Salmonella typhi)","Vancomycin-intermediate Staphylococcus aureus (VISA)","Vancomycin-resistant Staphylococcus aureus (VRSA)","Varicella (Chickenpox)","Venezuelan equine encephalitis virus neuroinvasive disease","Venezuelan equine encephalitis virus non-neuroinvasive disease","Vibriosis (non-cholera Vibrio species infections)","West Nile virus neuroinvasive disease","West Nile virus non-neuroinvasive disease","Western equine encephalitis virus neuroinvasive disease","Western equine encephalitis virus non-neuroinvasive disease","Yellow fever","Yersiniosis"]
    wordlist[rand(wordlist.size)]
  end
  
  def get_random_jurisdiction()
    wordlist = ["Out of State","Weber-Morgan Health Department","Wasatch County Health Department","Utah State","Utah County Health Department","TriCounty Health Department","Tooele County Health Department","Summit County Public Health Department","Southwest Utah Public Health Department","Southeastern Utah District Health Department","Salt Lake Valley Health Department","Davis County Health Department","Central Utah Public Health Department","Bear River Health Department","Unassigned"]
    wordlist[rand(wordlist.size)]
  end

  def click_logo(browser)
    browser.click 'logo'
    browser.wait_for_page_to_load($load_time)
  end
  
  def click_nav_new_cmr(browser)
    browser.open "/trisano/cmrs/new"
    browser.wait_for_page_to_load($load_time)
    return (browser.is_text_present("New Morbidity Event") and
        browser.is_text_present("New CMR") and
        browser.is_element_present("link=Back to list") and
        browser.is_element_present("disable_tabs"))
  end
  
  def click_nav_cmrs(browser)
    browser.click 'link=CMRS'
    browser.wait_for_page_to_load($load_time)
    return (browser.is_text_present("List Morbidity Events") and
        browser.is_text_present("Existing Reports") and
        browser.is_element_present("link=CMRS"))
  end
  
  def click_nav_search(browser)
    browser.click 'link=SEARCH'
    browser.wait_for_page_to_load($load_time)
    return (browser.is_element_present("link=People Search") and
        browser.is_element_present("link=Event Search"))  
  end
  
  def click_nav_forms(browser)
    browser.click 'link=FORMS'
    browser.wait_for_page_to_load($load_time)
    return (browser.is_text_present("Form Information") and
        browser.is_text_present("Diseases") and
        browser.is_text_present("Jurisdiction") and
        browser.is_text_present("Event Type") and
        browser.is_element_present("//input[@value='Upload']") and
        browser.is_element_present("//input[@id='form_import']") and
        browser.is_element_present("//input[@value='Create new form']")
    )
  end
  
  def click_nav_admin(browser)
    browser.click 'link=ADMIN'
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Admin Dashboard"))
  end
  
  def edit_cmr(browser)
    browser.click "link=Edit"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Person Information") and
        browser.is_text_present("Street number"))
  end

  def show_cmr(browser)
    browser.click "link=Show"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Person Information") and
        browser.is_text_present("Street number"))
  end

  def save_and_exit(browser)
    browser.click "save_and_exit_btn"
    browser.wait_for_page_to_load($load_time)
    browser.is_text_present("successfully").should be_true
    return true
  end

  def save_cmr(browser)
    save_and_exit(browser)
  end

  def save_and_continue(browser)
    browser.click "save_and_continue_btn"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("successfully"))
  end
  
  # Clicks the print button and points the browser at the print window.
  # 
  # To close the window after inspecting it, do something like the following:
  # @browser.close()
  # @browser.select_window 'null'
  def print_cmr(browser, note = 0)
    if note == 1
      browser.click "link=With Notes"
    else
      browser.click "link=Print"
    end
    browser.wait_for_pop_up '_blank', $load_time
    browser.select_window '_blank'
    return(browser.is_text_present('Utah Public Health'))
  end
  
  #NOTE: This only works for multiple labs if you save the CMR with each new lab report
  def add_lab_result(browser, result_attributes, index = 1)
    click_core_tab(browser, LABORATORY)
    browser.click("link=Add a new lab result") unless index == 1
    sleep(1)
    #TODO verify this works for multiples...
    type_field_by_order(browser, "lab_name", 0, result_attributes[:lab_name])
    type_field_by_order(browser, "test_type", 0, result_attributes[:lab_test_type])
    type_field_by_order(browser, "lab_result", 0, result_attributes[:lab_result_text])
    result_xpath = "//div[@id='labs']/div[1]/div[starts-with(@class,'lab_result')][#{index}]//"
    browser.select(result_xpath + "select[contains(@id, 'interpretation')]", result_attributes[:lab_interpretation])
    browser.select(result_xpath + "select[contains(@id, 'specimen_source_id')]", result_attributes[:lab_specimen_source])
    browser.type(result_xpath + "input[contains(@id, 'collection_date')]", result_attributes[:lab_collection_date])
    browser.type(result_xpath + "input[contains(@id, 'lab_test_date')]", result_attributes[:lab_test_date])
    browser.select(result_xpath + "select[contains(@id, '_specimen_sent_to_uphl_yn_id')]", "label=#{result_attributes[:sent_to_uphl]}")
  end

  def add_reporting_info(browser, result_attributes)
    click_core_tab(browser, REPORTING)
    @browser.click("//a[@id='add_reporting_agency_link']")
    sleep(1)
    type_field_by_order(browser, "morbidity_event_active_reporting_agency_name", 0, result_attributes[:agency])
    browser.type "morbidity_event_active_reporting_agency_first_name", result_attributes[:first_name]
    browser.type "morbidity_event_active_reporting_agency_last_name", result_attributes[:last_name]
    browser.select "morbidity_event_active_reporting_agency_entity_location_type_id", result_attributes[:phone_type]
    browser.type "morbidity_event_active_reporting_agency_area_code", result_attributes[:area_code]
    browser.type "morbidity_event_active_reporting_agency_extension", result_attributes[:extension]
    browser.type "morbidity_event_active_reporting_agency_phone_number", result_attributes[:phone_number]
    browser.type "morbidity_event_results_reported_to_clinician_date", result_attributes[:clinician_date]
    browser.type "morbidity_event_first_reported_PH_date", result_attributes[:PH_date]
  end

  def add_treatment(browser, result_attributes, index = 1)
    click_core_tab(browser, CLINICAL)
    browser.click("link=Add a treatment") unless index == 1
    sleep(1)
    browser.select("//div[@class='treatment'][#{index}]//select", result_attributes[:treatment_given])
    browser.type("//div[@class='treatment'][#{index}]//input[contains(@name, '[treatment]')]",    result_attributes[:treatment])
    browser.type("//div[@class='treatment'][#{index}]//input[contains(@name, 'treatment_date')]", result_attributes[:treatment_date])
  end
  
  def navigate_to_people_search(browser)
    click_nav_search(browser)
    @browser.click('link=People Search')
    @browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("People Search") and 
        browser.is_text_present("Name") and
        browser.is_text_present("Date of birth"))
  end
  
  def navigate_to_cmr_search(browser)
    click_nav_search(browser)
    @browser.click('link=Event Search')
    @browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Search") and 
        browser.is_text_present("By name") and
        browser.is_text_present("Additional criteria") and
        browser.is_text_present("Date or year of birth"))
  end
  
  #Use click_link_by_order to click the Nth element in a list of links of the same element type
  def click_link_by_order(browser, element_id_prefix, order)
    links = browser.get_all_links
    links.delete_if{|link| link.index(element_id_prefix) == nil}
    browser.click(links[order-1])
  end
  
  def type_field_by_order(browser, element_id_prefix, order, value)
    fields = browser.get_all_fields
    fields.delete_if{|field| field.index(element_id_prefix) != 0}
    browser.type(fields[order], value)
  end
  
  # Use click_resource methods from any standard resource index page
  def click_resource_edit(browser, resource, name)
    id = get_resource_id(browser, name)
    if (id > 0)
      if (resource == "cmrs")
        browser.click "//a[contains(@onclick, '/trisano/" + resource + "/" + id.to_s + "/edit')]"
      else
        browser.click "//a[contains(@href, '/trisano/" + resource + "/" + id.to_s + "/edit')]"
      end
      
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_resource_show(browser, resource, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@onclick, '/trisano/" + resource + "/" + id.to_s + "')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def create_simplest_cmr(browser, last_name)
    click_nav_new_cmr(browser)
    browser.type "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name", last_name
    yield browser if block_given?
    return save_cmr(browser)
  end

  def create_basic_investigatable_cmr(browser, last_name, disease_label, jurisdiction_label=nil)
    click_nav_new_cmr(browser)
    browser.type "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name", last_name
    browser.type("morbidity_event_address_attributes_street_number", "22")
    browser.type("morbidity_event_address_attributes_street_name", "Happy St.")
    click_core_tab(browser, CLINICAL)
    browser.select "morbidity_event_disease_event_attributes_disease_id", "label=#{disease_label}"
    click_core_tab(browser, ADMIN)
    browser.select "morbidity_event_jurisdiction_attributes_secondary_entity_id", "label=#{jurisdiction_label}" if jurisdiction_label
    yield browser if block_given?
    return save_cmr(browser)
  end
  
  def answer_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_answer_id(browser, question_text)
    begin
      browser.type("#{INVESTIGATOR_ANSWER_ID_PREFIX}#{answer_id}", answer) == "OK"
    rescue
      return false
    end
    return true
  end

  def watch_for_core_field_spinner(core_field, browser=@browser, &proc)
    css_selector = %Q{img[id$="[#{core_field}]_spinner"]}
    watch_for_spinner(css_selector, browser, &proc)
  end

  def watch_for_answer_spinner(question_text, browser=@browser, &proc)
    answer_id = get_investigator_answer_id(browser, question_text)
    css_selector = "img[id=investigator_answer_#{answer_id}_spinner]"
    watch_for_spinner(css_selector, browser, &proc)
  end

  def watch_for_spinner(css_selector, browser=@browser, &proc)
    script = "selenium.browserbot.getCurrentWindow().$$('#{css_selector}').first().visible()"
    proc.call unless proc.nil?
    browser.wait_for_condition("#{script} == true", 3000).should == "OK"
    browser.wait_for_condition("#{script} == false", 3000).should == "OK"
  end
  
  def answer_multi_select_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_answer_id(browser, question_text)
    begin
      browser.select("#{INVESTIGATOR_ANSWER_ID_PREFIX}#{answer_id}", answer) == "OK"
    rescue
      return false
    end
    return true
  end
  
  def answer_check_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_click_answer_id(browser, question_text)
    begin
      browser.click("investigator_answer_#{answer_id}_#{answer}") == "OK"
    rescue
      return false
    end
    return true
  end
  
  def answer_radio_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_click_answer_id(browser, question_text)
    begin
      browser.click("investigator_answer_#{answer_id}_#{answer}") == "OK"
    rescue
      return false
    end
    return true
  end
    
  def switch_user(browser, user_id)
    browser.select("user_id", "label=#{user_id}")
    browser.wait_for_page_to_load "30000"
    return browser.is_text_present("#{user_id}:")
  end
  
  def add_view(browser, name)
    browser.click("add-tab")
    wait_for_element_present("new-view-form")
    browser.type("view_element_name", name)
    browser.click "//input[contains(@id, 'create_view_submit')]"
    wait_for_element_not_present("new-view-form")
    if browser.is_text_present(name)
      return browser.get_value("id=modified-element")
    else
      return false
    end
  end
  
  def add_section_to_view(browser, view_name, section_attributes = {})
    element_id = get_form_element_id(browser, view_name, VIEW_ID_PREFIX)
    browser.click("add-section-#{element_id}")
    wait_for_element_present("new-section-form", browser)
    browser.type("section_element_name", section_attributes[:section_name])
    browser.type("section_element_description", section_attributes[:description]) unless section_attributes[:description].nil?
    browser.type("section_element_help_text", section_attributes[:help_text]) unless section_attributes[:help_text].nil?
    browser.click "//input[contains(@id, 'create_section_submit')]"
    wait_for_element_not_present("new-section-form", browser)
    if browser.is_text_present(section_attributes[:section_name])
      return browser.get_value("id=modified-element")
    else
      return false      
    end
  end

  # Takes the name of the tab to which the question should be added and the question's attributes.  
  def add_question_to_view(browser, element_name, question_attributes = {})
    return add_question_to_element(browser, element_name, VIEW_ID_PREFIX, question_attributes)
  end
  
  # Takes the name of the section to which the question should be added and the question's attributes.
  def add_question_to_section(browser, element_name, question_attributes = {})
    return add_question_to_element(browser, element_name, SECTION_ID_PREFIX, question_attributes)
  end
  
  # Takes the name of the follow-up container to which the question should be added and the question's attributes.
  def add_question_to_follow_up(browser, element_name, question_attributes = {})
    #    puts 'element_name: ' + element_name
    #    puts 'FOLLOW_UP_ID_PREFIX: ' + FOLLOW_UP_ID_PREFIX
    #    puts question_attributes.to_s
    return add_question_to_element(browser, element_name, FOLLOW_UP_ID_PREFIX, question_attributes)
  end
  
  # Takes the name of the before core field confg to which the question should be added and the question's attributes.
  def add_question_to_before_core_field_config(browser, element_name, question_attributes = {})
    return add_question_to_core_field_config(browser, element_name, BEFORE_CORE_FIELD_ID_PREFIX, question_attributes)
  end
  
  # Takes the name of the after core field confg to which the question should be added and the question's attributes.
  def add_question_to_after_core_field_config(browser, element_name, question_attributes = {})
    return add_question_to_core_field_config(browser, element_name, AFTER_CORE_FIELD_ID_PREFIX, question_attributes)
  end

  def add_all_questions_from_group_to_view(browser, element_name, group_name)

    element_id = get_form_element_id(browser, element_name, VIEW_ID_PREFIX)
    browser.click("add-question-#{element_id}")
    wait_for_element_present("new-question-form", browser)
    browser.click("link=Show all groups")
    
    # Debt: If this UI sticks, add something to key off of instead of using this sleep
    sleep(2)
    
    browser.click("link=Click to add all questions in group: #{group_name}")
    wait_for_element_not_present("new-question-form", browser)
    
    if browser.is_text_present(group_name)
      return true
    else
      return false      
    end
  end
  
  # Takes the question text of the question to which the follow-up should be added and the follow-up's attributes
  def add_follow_up_to_question(browser, question_text, condition)
    return add_follow_up_to_element(browser, question_text, QUESTION_ID_PREFIX, condition)
  end
  
  # Takes the name of the view to which the follow-up should be added and the follow-up's attributes.
  def add_core_follow_up_to_view(browser, element_name, condition, core_label)
    return add_follow_up_to_element(browser, element_name, VIEW_ID_PREFIX, condition, core_label)
  end
  
  def add_core_follow_up_to_after_core_field(browser, element_name, condition, core_label)
    return add_follow_up_to_core_field_config(browser, element_name, AFTER_CORE_FIELD_ID_PREFIX, condition, core_label)
  end

  def add_invalid_core_follow_up_to_view(browser, element_name, condition, invalid_core_path)
    element_id = get_form_element_id(browser, element_name, VIEW_ID_PREFIX)
    browser.click("add-follow-up-#{element_id}")
    wait_for_element_present("new-follow-up-form", browser)
    browser.type "model_auto_completer_tf", condition
    browser.select "follow_up_element_core_path", "label=Patient birth gender"
    browser.get_eval("element = window.document.getElementById(\"follow_up_element_core_path\").options[1]; element.value = '#{invalid_core_path}'; element.selected = true")
    browser.click "//input[contains(@id, 'create_follow_up_submit')]"
    wait_for_element_not_present("new-follow-up-form", browser)
  end
  
  
  def edit_core_follow_up(browser, element_name, condition, core_label)
    element_id = get_form_element_id(browser, element_name, FOLLOW_UP_ID_PREFIX)
    browser.click("edit-follow-up-#{element_id}")
    wait_for_element_present("edit-follow-up-form", browser)
    browser.type "model_auto_completer_tf", condition
    sleep 1 # Give the type ahead a second to breath, otherwise the edit doesn't stick
    browser.select "follow_up_element_core_path", "label=#{core_label}"
    browser.click "//input[contains(@id, 'edit_follow_up_submit')]"
    wait_for_element_not_present("edit-follow-up-form", browser)
  end
  
  def edit_follow_up(browser, element_name, condition)
    element_id = get_form_element_id(browser, element_name, FOLLOW_UP_ID_PREFIX)
    browser.click("edit-follow-up-#{element_id}")
    wait_for_element_present("edit-follow-up-form", browser)
    browser.type "follow_up_element_condition", condition
    browser.click "//input[contains(@id, 'edit_follow_up_submit')]"
    wait_for_element_not_present("edit-follow-up-form", browser)
  end
  
  def edit_section(browser, element_name, section_text)
    element_id = get_form_element_id(browser, element_name, SECTION_ID_PREFIX)
    browser.click("edit-section-#{element_id}")
    wait_for_element_present("section-element-edit-form", browser)
    browser.type "section_element_name", section_text
    browser.click "//input[contains(@id, 'edit_section_submit')]"
    wait_for_element_not_present("edit-section-form", browser)
  end
  
  def add_value_set_to_question(browser, question_text, value_set_name, value_attributes=[])
    element_id = get_form_element_id(browser, question_text, QUESTION_ID_PREFIX)
    browser.click("add-value-set-#{element_id}")
    wait_for_element_present("new-value-set-form", browser)
    browser.type "value_set_element_name", value_set_name
    browser.click "//input[contains(@id, 'create_value_set_submit')]"
    wait_for_element_not_present("new-value-set-form")
    browser.is_text_present(value_set_name).should be_true
    value_set_id = browser.get_value("id=modified-element")

    value_attributes.each do |attributes|
      browser.click("add-value-#{value_set_id}")
      wait_for_element_present("new-value-form", browser)
      browser.type "value_element_name", attributes[:name]
      browser.type "value_element_code", attributes[:code] if attributes[:code]
      browser.click "//input[contains(@id, 'create_value_submit')]"
      wait_for_element_not_present("new-value-form")
    end

    if browser.is_text_present(value_set_name)
      return true
    else
      return false      
    end
  end
  
  def add_value_set_from_library_to_question(browser, question_text, value_set_name)
    element_id = get_form_element_id(browser, question_text, QUESTION_ID_PREFIX)
    browser.click("add-value-set-#{element_id}")
    wait_for_element_present("new-value-set-form", browser)
    browser.type "lib_filter", value_set_name
    sleep(2)
    browser.click "link=#{value_set_name}"
    wait_for_element_not_present("new-value-set-form")

    # Debt: Not the best test since it could be on the form already
    if browser.is_text_present(value_set_name)
      return true
    else
      return false      
    end
  end
  
  def add_core_tab_configuration(browser, core_view_name)
    browser.click("add-core-tab")
    wait_for_element_present("new-core-view-form", browser)
    browser.select("core_view_element_name", "label=#{core_view_name}")
    browser.click "//input[contains(@id, 'create_core_view_submit')]"
    wait_for_element_not_present("new-core-view-form", browser)
  end
  
  def add_core_field_config(browser, core_field_name)
    browser.click("add-core-field")
    wait_for_element_present("new_core_field_element", browser)
    browser.select("core_field_element_core_path", "label=#{core_field_name}")
    browser.click "//input[contains(@id, 'create_core_field_submit')]"
    wait_for_element_not_present("new_core_field_element", browser)
  end
  
  def add_question_to_library(browser, question_text, group_name=nil)
    element_id = get_form_element_id(browser, question_text, QUESTION_ID_PREFIX)
    browser.click("add-element-to-library-#{element_id}")
    wait_for_element_present("new-group-form")

    if (group_name.nil?)
      browser.click "link=No Group"
    else
      begin
        browser.click "link=Add element to: #{group_name}"
      rescue
        browser.type "group_element_name", group_name
        browser.click "group_element_submit"  
        sleep(2)
        browser.click "link=Add element to: #{group_name}"
      end
      
    end
   
    sleep(2)
    browser.click "link=Close"
    # Debt: Find something to do an assertion off of
  end
  
  def add_value_set_to_library(browser, value_set_name, group_name=nil)
    element_id = get_form_element_id(browser, value_set_name, VALUE_SET_ID_PREFIX)
    browser.click("add-element-to-library-#{element_id}")
    wait_for_element_present("new-group-form")

    if (group_name.nil?)
      browser.click "link=No Group"
    else
      browser.type "group_element_name", group_name
      browser.click "group_element_submit"  
      sleep(2)
      browser.click "link=Add element to: #{group_name}"
    end
   
    sleep(2)
    browser.click "link=Close"
    # Debt: Find something to do an assertion off of
  end
  
  # The delete helpers that follow could be dried up a bit, passing through to a single
  # delete_element method, but that would probably involve synching up the ids used 
  # on the action links so they use underscores instead of dashes as separators:
  #    * Use delete_question_34 instead of delete-question-34 in the views
  #    * Then utilize the element prefix constants to dry things up
  
  # Deletes the view with the name provided
  def delete_view(browser, name)
    element_id = get_form_element_id(browser, name, VIEW_ID_PREFIX)
    browser.click("delete-view-#{element_id}")
    browser.get_confirmation()
    return(!browser.is_text_present("delete-view-#{element_id}"))
  end
  
  # Deletes the section with the name provided
  def delete_section(browser, name)
    element_id = get_form_element_id(browser, name, SECTION_ID_PREFIX)
    browser.click("delete-section-#{element_id}")
    browser.get_confirmation()   
    return(!browser.is_text_present("delete-section-#{element_id}"))
  end
  
  # Deletes the group with the name provided
  def delete_group(browser, name)
    element_id = get_form_element_id(browser, name, GROUP_ID_PREFIX)
    browser.click("delete-group-#{element_id}")
    browser.get_confirmation()   
    return(!browser.is_text_present("delete-group-#{element_id}"))
  end
  
  # Deletes the question with the name provided
  def delete_question(browser, name)
    element_id = get_form_element_id(browser, name, QUESTION_ID_PREFIX)
    browser.click("delete-question-#{element_id}")
    browser.get_confirmation()
    return(!browser.is_text_present("delete-question-#{element_id}"))
  end
  
  def delete_question_from_library(browser, name)
    element_id = get_library_element_id(browser, name, QUESTION_ID_PREFIX)
    browser.click("delete-question-#{element_id}")
    browser.get_confirmation()
    return(!browser.is_text_present("delete-question-#{element_id}"))
  end
  
  # Deletes the value set with the name provided
  def delete_value_set(browser, name)
    element_id = get_form_element_id(browser, name, VALUE_SET_ID_PREFIX)
    browser.click("delete-value-set-#{element_id}")
    browser.get_confirmation()   
    return(!browser.is_text_present("delete-value-set-#{element_id}"))
  end
  
  # Deletes the core field config with the name provided
  def delete_core_field_config(browser, name)
    element_id = get_form_element_id(browser, name, CORE_FIELD_ID_PREFIX)
    browser.click("delete-core-field-#{element_id}")
    browser.get_confirmation()   
    return(!browser.is_text_present("delete-core-field-#{element_id}"))
  end
  
  # Deletes the follow up with the name provided
  def delete_follow_up(browser, name)
    element_id = get_form_element_id(browser, name, FOLLOW_UP_ID_PREFIX)
    browser.click("delete-follow-up-#{element_id}")
    browser.get_confirmation()
    sleep(2)
    return(!browser.is_text_present("delete-follow-up-#{element_id}"))
  end
  
  def publish_form(browser)
    browser.click '//input[@value="Publish"]'
    return false if browser.is_editable('//input[@value="Publishing..."]')
    browser.wait_for_page_to_load($publish_time)
    return(browser.is_text_present("Form was successfully published "))
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
    id_start_position = html_source.rindex(INVESTIGATOR_QUESTION_ID_PREFIX, question_position)
    id_end_position = html_source.index("\"", id_start_position) -1
    answer_input_element_id = html_source[id_start_position..id_end_position]
    tab_element_id = TAB_ELEMENT_IDS_BY_NAME[tab_name]
    assert_contains(browser, tab_element_id, answer_input_element_id)
  end
  
  def get_record_number(browser)
    html_source = browser.get_html_source
    text_position = html_source.index("Record number</label>")
    record_number_start_position = html_source.index(Time.now.year.to_s, text_position)
    record_number_end_position = html_source.index("</span>", record_number_start_position) -1
    html_source[record_number_start_position..record_number_end_position]
  end

  def get_full_cmr_hash()
    @cmr_fields = {
      # Patient fields
      "morbidity_event_active_patient__person_last_name" => get_unique_name(1),
      "morbidity_event_active_patient__person_first_name" => get_unique_name(1),
      "morbidity_event_active_patient__person_middle_name" => get_unique_name(1),
      "morbidity_event_active_patient__person_birth_date" => "1/1/1974",
      "morbidity_event_active_patient__person_approximate_age_no_birthday" => "22",
      "morbidity_event_active_patient__person_date_of_death" => "1/1/1974",      
      "morbidity_event_active_patient__person_birth_gender_id" => "Female",
      "morbidity_event_active_patient__person_ethnicity_id" => "Not Hispanic or Latino",
      "morbidity_event_active_patient__person_primary_language_id" => "Hmong",
      "morbidity_event_active_patient__address_street_number" => "123",
      "morbidity_event_active_patient__address_street_name" => get_unique_name(1),
      "morbidity_event_active_patient__address_unit_number" => "2",
      "morbidity_event_active_patient__address_city" => get_unique_name(1),
      "morbidity_event_active_patient__address_postal_code" => "84601",
      "morbidity_event_active_patient__address_county_id" => "Beaver",
      "morbidity_event_active_patient__address_state_id" => "Utah",
      "morbidity_event_active_patient__new_telephone_attributes__entity_location_type_id" => 'Work',
      "morbidity_event_active_patient__new_telephone_attributes__area_code" => "801",
      "morbidity_event_active_patient__new_telephone_attributes__phone_number" => "555-7894",
      "morbidity_event_active_patient__new_telephone_attributes__extension" => "147",
      "morbidity_event_active_patient__race_ids" => "Asian",
      #Disease fields
      "morbidity_event_disease_disease_onset_date" => "1/1/1974",
      "morbidity_event_disease_date_diagnosed" => "1/1/1974",
      "morbidity_event_disease_disease_id" => "Amebiasis",
      #Status fields
      "morbidity_event_disease_died_id" => "Yes",
      "morbidity_event_imported_from_id" => "Utah",
      #Hospital fields
      "morbidity_event_new_hospital_attributes__admission_date" => "1/1/1974",
      "morbidity_event_new_hospital_attributes__discharge_date" => "1/1/1974",
      "morbidity_event_new_hospital_attributes__secondary_entity_id" => "Ashley Regional Medical Center",
      "morbidity_event_disease_hospitalized_id" => "Yes",
      #Diagnosis field
      "morbidity_event_new_diagnostic_attributes__secondary_entity_id" => "Alta View Hospital",
      #Treatment fields
      "morbidity_event_active_patient__new_treatment_attributes__treatment_given_yn_id" => "Yes",
      "morbidity_event_active_patient__new_treatment_attributes__treatment" => NedssHelper.get_unique_name(1),
      #Clinician fields
      "morbidity_event_new_clinician_attributes__last_name" => NedssHelper.get_unique_name(1),
      "morbidity_event_new_clinician_attributes__first_name" => NedssHelper.get_unique_name(1),
      "morbidity_event_new_clinician_attributes__middle_name" => NedssHelper.get_unique_name(1),
      "morbidity_event_new_clinician_attributes__area_code" => "501",
      "morbidity_event_new_clinician_attributes__phone_number" => "555-1645",
      "morbidity_event_new_clinician_attributes__extension" => "1645",
      #lab result fields
      "event[new_lab_attributes][][name]" => NedssHelper.get_unique_name(2),
      "morbidity_event_new_lab_attributes__specimen_source_id" => "Blood",
      "morbidity_event_new_lab_attributes__specimen_sent_to_uphl_yn_id" => "Yes",
      "morbidity_event_new_lab_attributes__lab_result_text" => NedssHelper.get_unique_name(1),
      "morbidity_event_new_lab_attributes__collection_date" => "1/1/1974",
      "morbidity_event_new_lab_attributes__lab_test_date" => "1/1/1974",
      #contact fields
      "morbidity_event_new_contact_attributes__last_name" => NedssHelper.get_unique_name(1),
      "morbidity_event_new_contact_attributes__first_name" => NedssHelper.get_unique_name(1),
      "morbidity_event_new_contact_attributes__area_code" => "840",
      "morbidity_event_new_contact_attributes__phone_number" => "555-7457",
      "morbidity_event_new_contact_attributes__extension" => "4557"
    }
    return(@cmr_fields)
  end

  def get_question_investigate_div_id(browser, question_text)
    element_id_prefix = "question_investigate_"
    html_source = browser.get_html_source
    name_position = html_source.index(question_text)
    id_start_position = html_source.rindex("#{element_id_prefix}", name_position) + element_id_prefix.length
    id_end_position = html_source.index("\"", id_start_position)-1
    html_source[id_start_position..id_end_position]
  end

  def case_checkboxes(browser)
    browser.get_all_fields().select do |id|
      %w(Unknown Confirmed Probable Suspect Not_a_Case Chronic_Carrier Discarded).include? id
    end
  end

  def add_note(browser, note_text, options={:is_admin => false})
    browser.type('css=textarea[id$=_note]', note_text)
    browser.click('css=input[id$=_note_type]') if options[:is_admin]
  end
  
  def note_count(browser, note_type="All")
    if note_type == "All"
      return browser.get_eval(%Q{selenium.browserbot.getCurrentWindow().$$('span.note-type').length}).to_i
    else
      browser.get_eval("selenium.browserbot.getCurrentWindow().$$('span.note-type').findAll(function(n) { return n.innerHTML.indexOf('#{note_type}') > 0; }).length").to_i
    end
  end

  def add_task(browser, task_attributes={})
    browser.click("link=Add Task")
    browser.wait_for_page_to_load($load_time)
    browser.type("task_name", task_attributes[:task_name])
    browser.type("task_notes", task_attributes[:task_notes]) if task_attributes[:task_notes]
    browser.select("task_category_id", task_attributes[:task_category]) if task_attributes[:task_category]
    browser.select("task_priority", task_attributes[:task_priority]) if task_attributes[:task_priority]
    browser.type("task_due_date", task_attributes[:task_due_date]) if task_attributes[:task_due_date]
    browser.type("task_until_date", task_attributes[:task_until_date]) if task_attributes[:task_until_date]
    browser.select("task_repeating_interval", task_attributes[:task_repeating_interval]) if task_attributes[:task_repeating_interval]
    browser.select("task_user_id", task_attributes[:task_user_id]) if task_attributes[:task_user_id]
    browser.click("task_submit")
    browser.wait_for_page_to_load($load_time)
    return browser.is_text_present("Task was successfully created.")
  end

  # Debt: Dups add_task
  def edit_task(browser, task_attributes={})
    browser.click("link=Edit task")
    browser.wait_for_page_to_load($load_time)
    browser.type("task_name", task_attributes[:task_name])
    browser.type("task_notes", task_attributes[:task_notes]) if task_attributes[:task_notes]
    browser.select("task_category_id", task_attributes[:task_category]) if task_attributes[:task_category]
    browser.select("task_status", task_attributes[:task_status]) if task_attributes[:task_status]
    browser.select("task_priority", task_attributes[:task_priority]) if task_attributes[:task_priority]
    browser.type("task_due_date", task_attributes[:task_due_date]) if task_attributes[:task_due_date]
    browser.select("task_user_id", task_attributes[:task_user_id]) if task_attributes[:task_user_id]
    browser.click("task_submit")
    browser.wait_for_page_to_load($load_time)
    return browser.is_text_present("Task was successfully updated.")
  end

  def update_task_status(browser, status_label)
    browser.select('css=select[id^=task-status-change-]', "label=#{status_label}")
    sleep 3 # Debt: Feed off something else so this sleep can get dumped
  end

  def change_task_filter(browser, options = {})
    browser.click("link=Change filter")
    sleep 3
    browser.type("look_ahead", options[:look_ahead]) unless options[:look_ahead].nil?
    browser.type("look_back", options[:look_back]) unless options[:look_back].nil?
    browser.click("update_tasks_filter")
    browser.wait_for_page_to_load($load_time)
  end

  def is_text_present_in(browser, html_id, text)
    result = browser.get_eval("selenium.browserbot.getCurrentWindow().$('#{html_id}').innerHTML.indexOf('#{text}') > 0")
    (result == "false") ? false : true
  end

  def date_for_calendar_select(date)
    date.strftime("%B %d, %Y")
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
    fill_in_question_attributes(browser, element_id, question_attributes)
  end
  
  def add_question_to_core_field_config(browser, element_name, element_id_prefix, question_attributes)
    element_id = get_form_element_id_for_core_field(browser, element_name, element_id_prefix)
    fill_in_question_attributes(browser, element_id, question_attributes)
  end
  
  def fill_in_question_attributes(browser, element_id, question_attributes)
    browser.click("add-question-#{element_id}")
    wait_for_element_present("new-question-form", browser)
    browser.type("question_element_question_attributes_question_text", question_attributes[:question_text])
    browser.select("question_element_question_attributes_data_type", "label=#{question_attributes[:data_type]}")
    browser.select("question_element_export_column_id", "label=#{question_attributes[:export_column_id]}") if question_attributes.include? :export_column_id
    browser.select("question_element_question_attributes_style", "label=#{question_attributes[:style]}") if question_attributes.include? :style
    browser.click("question_element_is_active_#{question_attributes[:is_active].to_s}") if question_attributes.include? :is_active
    browser.type("question_element_question_attributes_short_name", question_attributes[:short_name])  if question_attributes.include? :short_name
    browser.type("question_element_question_attributes_help_text", question_attributes[:help_text]) if question_attributes[:help_text]
    browser.click "//input[contains(@id, 'create_question_submit')]"
    wait_for_element_not_present("new-question-form", browser)
    if browser.is_text_present(question_attributes[:question_text])
      return true
    else
      return false      
    end
  end
  
  def add_follow_up_to_element(browser, element_name, element_id_prefix, condition, core_label=nil)
    element_id = get_form_element_id(browser, element_name, element_id_prefix)
    browser.click("add-follow-up-#{element_id}")
    wait_for_element_present("new-follow-up-form", browser)
    if core_label.nil?
      browser.type "follow_up_element_condition", condition
    else
      browser.type "model_auto_completer_tf", condition
    end
    
    browser.select "follow_up_element_core_path", "label=#{core_label}" unless core_label.nil?
    browser.click "//input[contains(@id, 'create_follow_up_submit')]"
    wait_for_element_not_present("new-follow-up-form", browser)
  end
      
  def add_follow_up_to_core_field_config(browser, element_name, element_id_prefix, condition, core_label=nil)
    element_id = get_form_element_id_for_core_field(browser, element_name, element_id_prefix)
    browser.click("add-follow-up-#{element_id}")
    wait_for_element_present("new-follow-up-form", browser)
    if core_label.nil?
      browser.type "follow_up_element_condition", condition
    else
      browser.type "model_auto_completer_tf", condition
    end
    
    browser.select "follow_up_element_core_path", "label=#{core_label}" unless core_label.nil?
    browser.click "//input[contains(@id, 'create_follow_up_submit')]"
    wait_for_element_not_present("new-follow-up-form", browser)
  end

  # Goes in reverse from the name provided, looking for the magic string of
  # element_prefix_<id>
  # 
  # The retry accounts for the fact that you may run into paths that just so
  # happen to contain the element prefix string.
  def get_form_element_id(browser, name, element_id_prefix)
    retry_count = 0
    element_prefix_length = element_id_prefix.size
    html_source = browser.get_html_source
    # Start from form_children to avoid finding something up in the top portion of the page
    name_position = html_source.index(name, html_source.index("form_children")) 
    
    begin
      id_start_position = html_source.rindex("#{element_id_prefix}", name_position) + element_prefix_length
      raise if html_source[id_start_position..id_start_position+1].to_i == 0
    rescue
      retry_count += 1
      name_position = id_start_position - (element_prefix_length+1)
      retry if retry_count < 5
    end
    
    id_end_position = html_source.index("\"", id_start_position)-1
    html_source[id_start_position..id_end_position]
  end
  
  def get_library_element_id(browser, name, element_id_prefix)
    retry_count = 0
    element_prefix_length = element_id_prefix.size
    html_source = browser.get_html_source
    # Start from form_children to avoid finding something up in the top portion of the page
    name_position = html_source.index(name, html_source.index("Library Administration")) 
    
    begin
      id_start_position = html_source.rindex("#{element_id_prefix}", name_position) + element_prefix_length
      raise if html_source[id_start_position..id_start_position+1].to_i == 0
    rescue
      retry_count += 1
      id_start_position.nil? ? name_position = 1 : name_position = id_start_position - (element_prefix_length+1) 
      retry if retry_count < 5
    end
    
    id_end_position = html_source.index("\"", id_start_position)-1
    html_source[id_start_position..id_end_position]
  end
  # Same as get_form_element_id except it doesn't do a reverse index looking for the start position.
  # Core field configs are different in that the name of the main core field config preceeds the two
  # containers for before and after configs.
  def get_form_element_id_for_core_field(browser, name, element_id_prefix)
    element_prefix_length = element_id_prefix.size
    html_source = browser.get_html_source
    name_position = html_source.index(name)
    id_start_position = html_source.index("#{element_id_prefix}", name_position) + element_prefix_length
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
 
  # This only works for investigator questions on contact events
  def get_investigator_click_answer_id(browser, question_text)
    html_source = browser.get_html_source
    question_position = html_source.index(question_text)
    id_start_position = html_source.index("investigator_answer_", question_position) + 20
    id_end_position = html_source.index("_", id_start_position) -1
    html_source[id_start_position..id_end_position]
  end
  
  def get_random_word
    wordlist = ["Lorem","ipsum","dolor","sit","amet","consectetuer","adipiscing","elit","Duis","sodales","dignissim","enim","Nunc","rhoncus","quam","ut","quam","Quisque","vitae","urna","Duis","nec","sapien","Proin","mollis","congue","mauris","Fusce","lobortis","tristique","elit","Phasellus","aliquam","dui","id","placerat","hendrerit","dolor","augue","posuere","tellus","at","ultricies","libero","leo","vel","leo","Nulla","purus","Ut","lacus","felis","tempus","at","egestas","nec","cursus","nec","magna","Ut","fringilla","aliquet","arcu","Vestibulum","ante","ipsum","primis","in","faucibus","orci","luctus","et","ultrices","posuere","cubilia","Curae","Etiam","vestibulum","urna","sit","amet","sem","Nunc","ac","ipsum","In","consectetuer","quam","nec","lectus","Maecenas","magna","Nulla","ut","mi","eu","elit","accumsan","gravida","Praesent","ornare","urna","a","lectus","dapibus","luctus","Integer","interdum","bibendum","neque","Nulla","id","dui","Aenean","tincidunt","dictum","tortor","Proin","sagittis","accumsan","nulla","Etiam","consectetuer","Etiam","eget","nibh","ut","sem","mollis","luctus","Etiam","mi","eros","blandit","in","suscipit","ut","vestibulum","et","velit","Fusce","laoreet","nulla","nec","neque","Nam","non","nulla","ut","justo","ullamcorper","egestas","In","porta","ipsum","nec","neque","Cras","non","metus","id","massa","ultrices","rhoncus","Donec","mattis","odio","sagittis","nunc","Vivamus","vehicula","justo","vitae","tincidunt","posuere","risus","pede","lacinia","dolor","quis","placerat","justo","arcu","ut","tortor","Aliquam","malesuada","lectus","id","condimentum","sollicitudin","arcu","mauris","adipiscing","turpis","a","sollicitudin","erat","metus","vel","magna","Proin","scelerisque","neque","id","urna","lobortis","vulputate","In","porta","pulvinar","urna","Cras","id","nulla","In","dapibus","vestibulum","pede","In","ut","velit","Aliquam","in","turpis","vitae","nunc","hendrerit","ullamcorper","Aliquam","rutrum","erat","sit","amet","velit","Nullam","pharetra","neque","id","pede","Phasellus","suscipit","ornare","mi","Ut","malesuada","consequat","ipsum","Suspendisse","suscipit","aliquam","nisl","Suspendisse","iaculis","magna","eu","ligula","Sed","porttitor","eros","id","euismod","auctor","dolor","lectus","convallis","justo","ut","elementum","magna","magna","congue","nulla","Pellentesque","eget","ipsum","Pellentesque","tempus","leo","id","magna","Cras","mi","dui","pellentesque","in","pellentesque","nec","blandit","nec","odio","Pellentesque","eget","risus","In","venenatis","metus","id","magna","Etiam","blandit","Integer","a","massa","vitae","lacus","dignissim","auctor","Mauris","libero","metus","aliquet","in","rhoncus","sed","volutpat","quis","libero","Nam","urna"]
    begin
      result = wordlist[rand(wordlist.size)]
      raise if result.nil?
    rescue Exception => ex
      result = wordlist[rand(wordlist.size)]
    end
    result

  end
  
  def get_resource_id(browser, name)
    html_source = browser.get_html_source
    pos1 = html_source.index(name)
    pos2 = html_source.index(/\d\/edit['"]/, pos1)
    pos3 = html_source.rindex("/", pos2)+1
    id = html_source[pos3..pos2]
    return id.to_i
  rescue => err
    return -1
  end

  # using the form name, get the form id from the forms index page
  def get_form_id(browser, form_name)
    html_source = browser.get_html_source
    pos1 = html_source.index(form_name)
    pos2 = html_source.index('forms/builder/', pos1) + 14
    pos3 = html_source.index('"', pos2)
    html_source[pos2...pos3]
  end

  def copy_form_and_open_in_form_builder(browser, form_name)
    browser.click("copy_form_#{get_form_id(browser, form_name)}")
    browser.wait_for_page_to_load($load_time)
    browser.is_text_present('Form was successfully copied.').should be_true
    browser.click('//input[@id="form_submit"]')
    browser.wait_for_page_to_load($load_time)
    browser.is_text_present('Form was successfully updated.').should be_true
    browser.is_text_present('Not Published').should be_true
    browser.click('link=Detail')
    browser.wait_for_page_to_load($load_time)
    true
  end    

  def assert_tooltip_exists(browser, tool_tip_text)
    browser.is_element_present("//img[contains(@src, 'help.png')]").should be_true
    browser.is_text_present(tool_tip_text).should be_true
    browser.is_visible("//span[contains(@id,'_help_text')]").should be_false
    browser.is_visible("//div[@id='WzTtDiV']").should be_false
    browser.mouse_over("//a[contains(@id,'_help_text')]")
    browser.mouse_move("//a[contains(@id,'_help_text')]")
    sleep(2)
    browser.is_visible("//div[@id='WzTtDiV']").should be_true
    browser.mouse_out("//a[contains(@id, '_help_text')]")
    sleep(2)
    browser.is_visible("//div[@id='WzTtDiV']").should be_false
    return true
  end
  
  def is_disease_active(browser, disease_name)
    html_source = browser.get_html_source
    start = html_source.index(disease_name) + disease_name.length
    html_source[start..start+100].index("Active").nil? ? false : true
  end
  
  def is_disease_inactive(browser, disease_name)
    html_source = browser.get_html_source
    start = html_source.index(disease_name) + disease_name.length
    html_source[start..start+100].index("Inactive").nil? ? false : true
  end

  def get_record_number(browser)
    source = browser.get_html_source
    label = '<label>Record number</label>'
    index_start = source.index(label) + label.length
    index_end = source.index('</span>', index_start)
    source[index_start...index_end].strip
  end
end
