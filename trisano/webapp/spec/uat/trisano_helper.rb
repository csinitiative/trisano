# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

module TrisanoHelper
  #Define constants for standard resources
  FORM = "forms"
  
  # Constants for the tab names
  DEMOGRAPHICS = "Demographics"
  CLINICAL = "Clinical"
  LABORATORY = "Laboratory"
  CONTACTS = "Contacts"
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
    when EPI
      browser.click('//li[5]/a/em')
    when REPORTING
      browser.click('//li[6]/a/em')
    when INVESTIGATION
      browser.click('//li[7]/a/em')
    when NOTES
      browser.click('//li[8]/a/em')
    when ADMIN
      browser.click('//li[9]/a/em')
    when PLACE
      browser.click('//li[1]/a/em')
    else
      puts("TAB NOT FOUND: " + tab_name)
    end
  end

  def get_random_disease()
    wordlist = ["African Tick Bite Fever","AIDS","Amebiasis","Anaplasma phagocytophilum","Anthrax","Aseptic meningitis","Bacterial meningitis, other","Botulism, foodborne","Botulism, infant","Botulism, other (includes wound)","Botulism, other unspecified","Botulism, wound","Brucellosis","Cache Valley virus neuroinvasive disease","Cache Valley virus non-neuroinvasive disease","California serogroup virus neuroinvasive disease","California serogroup virus non-neuroinvasive disease","Campylobacteriosis","Chancroid","Chlamydia trachomatis genital infection","Cholera (toxigenic Vibrio cholerae O1 or O139)","Coccidioidomycosis","Cryptosporidiosis","Cyclosporiasis","Dengue","Dengue hemorrhagic fever","Diphtheria","Eastern equine encephalitis virus neuroinvasive disease","Eastern equine encephalitis virus non-neuroinvasive disease","Ehrlichia chaffeensis","Ehrlichia ewingii","Ehrlichiosis/Anaplasmosis, undetermined","Encephalitis, post-chickenpox","Encephalitis, post-mumps","Encephalitis, post-other","Encephalitis, primary","Flu activity code (Influenza)","Giardiasis","Gonorrhea","Granuloma inguinale (GI)","Haemophilus influenzae, invasive disease","Hansen disease (Leprosy)","Hantavirus infection","Hantavirus pulmonary syndrome","Hemolytic uremic syndrome postdiarrheal","Hepatitis A, acute","Hepatitis B virus infection, chronic","Hepatitis B, acute","Hepatitis B, virus infection perinatal","Hepatitis C virus infection, past or present","Hepatitis C, acute","Hepatitis Delta co- or super-infection, acute (Hepatitis D)","Hepatitis E, acute","Hepatitis, viral unspecified","HIV Infection, adult","HIV Infection, pediatric","Human T-Lymphotropic virus type I infection (HTLV-I)","Human T-Lymphotropic virus type II infection (HTLV-II)","Influenza, animal isolates","Influenza, human isolates","Influenza-associated mortality","Japanese encephalitis virus neuroinvasive disease","Japanese encephalitis virus non-neuroinvasive disease","Lead poisoning","Legionellosis","Listeriosis","Lyme disease","Lymphogranuloma venereum (LGV)","Malaria","Measles (rubeola), total","Meningococcal disease (Neisseria meningitidis)","Methicillin- or oxicillin- resistant Staphylococcus aureus coagulase-positive (MRSA a.k.a. ORSA)","Monkeypox","Mucopurulent cervicitis (MPC)","Mumps","Neurosyphilis","Nongonococcal urethritis (NGU)","Novel influenza A virus infections","Pelvic Inflammatory Disease (PID), Unknown Etiology","Pertussis","Plague","Poliomyelitis, paralytic","Poliovirus infection, nonparalytic","Powassan virus neuroinvasive disease","Powassan virus non-neuroinvasive disease","Psittacosis (Ornithosis)","Q fever","Q fever, acute","Q fever, chronic","Rabies, animal","Rabies, human","Rocky Mountain spotted fever","Rubella","Rubella, congenital syndrome","Salmonellosis","Severe Acute Respiratory Syndrome (SARS)-associated Coronavirus disease (SARS-CoV)","Shiga toxin-producing Escherichia coli (STEC)","Shigellosis","Smallpox","St. Louis encephalitis virus neuroinvasive disease","St. Louis encephalitis virus non-neuroinvasive disease","Streptococcal disease, invasive, Group A","Streptococcal disease, invasive, Group B","Streptococcal disease, other, invasive, beta-hemolytic (non-group A and non-group B)","Streptococcal toxic-shock syndrome","Streptococcus pneumoniae invasive, drug-resistant (DRSP)","Streptococcus pneumoniae, invasive disease","Syphilis, congenital","Syphilis, early latent","Syphilis, late latent","Syphilis, late with clinical manifestations other than neurosyphilis","Syphilis, primary","Syphilis, secondary","Syphilis, total primary and secondary","Syphilis, unknown latent","Tetanus","Toxic-shock syndrome (staphylococcal)","Trichinellosis","Tuberculosis","Tularemia","Typhoid fever (caused by Salmonella typhi)","Vancomycin-intermediate Staphylococcus aureus (VISA)","Vancomycin-resistant Staphylococcus aureus (VRSA)","Varicella (Chickenpox)","Venezuelan equine encephalitis virus neuroinvasive disease","Venezuelan equine encephalitis virus non-neuroinvasive disease","Vibriosis (non-cholera Vibrio species infections)","West Nile virus neuroinvasive disease","West Nile virus non-neuroinvasive disease","Western equine encephalitis virus neuroinvasive disease","Western equine encephalitis virus non-neuroinvasive disease","Yellow fever","Yersiniosis"]
    wordlist[1 + rand(132)]
  end
  
  def get_random_jurisdiction()
    wordlist = ["Out of State","Weber-Morgan Health Department","Wasatch County Health Department","Utah State","Utah County Health Department","TriCounty Health Department","Tooele County Health Department","Summit County Public Health Department","Southwest Utah Public Health Department","Southeastern Utah District Health Department","Salt Lake Valley Health Department","Davis County Health Department","Central Utah Public Health Department","Bear River Health Department","Unassigned"]
    wordlist[1 + rand(14)]
  end
  
  def click_nav_new_cmr(browser)
    browser.click 'link=NEW CMR'
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
        browser.is_element_present("link=CMRS") and
        browser.is_element_present("link=Export All to CSV")) 
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
    return(browser.is_text_present("Admin Dashboard") and
        browser.is_element_present("link=Forms") and
        browser.is_element_present("link=Users") and
        browser.is_element_present("link=Codes") and
        browser.is_element_present("link=Event Queues") and
        browser.is_element_present("link=Diseases") and
        browser.is_element_present("link=Core Fields") and
        browser.is_element_present("link=CDC Export") and
        browser.is_element_present("link=IBIS Export") 
    )
  end
  
  def edit_cmr(browser)
    browser.click "link=Edit"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Person Information") and
        browser.is_text_present("Street number"))
  end
  
  def save_cmr(browser)
    browser.click "save_and_exit_btn"
    browser.wait_for_page_to_load($load_time)    
    return browser.is_text_present("successfully")
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
  def print_cmr(browser)
    browser.click "link=Print"
    browser.wait_for_pop_up '_blank', $load_time
    browser.select_window '_blank'
    return(browser.is_text_present('Utah Public Health'))
  end
  
  def add_contact(browser, contact_attributes, index = 1)
    click_core_tab(browser, CONTACTS)
    browser.click "link=Add a contact"
    sleep(1)
    browser.type("//div[@class='contact'][#{index}]//input[contains(@id, 'last_name')]", contact_attributes[:last_name])
    browser.type("//div[@class='contact'][#{index}]//input[contains(@id, 'first_name')]", contact_attributes[:first_name])
    browser.select("//div[@class='contact'][#{index}]//select[contains(@id, 'disposition')]", "label=#{contact_attributes[:disposition]}")
  end
  
  #NOTE: This only works for multiple labs if you save the CMR with each new lab report
  def add_lab_result(browser, result_attributes, index = 1)
    click_core_tab(browser, LABORATORY)
    browser.click("link=Add a new lab result") unless index == 1
    sleep(1)
        
    type_field_by_order(@browser, "model_auto_completer_tf", 0, result_attributes[:lab_name])
    @browser.type("morbidity_event_new_lab_attributes__test_type", result_attributes[:lab_test_type])
    @browser.type("morbidity_event_new_lab_attributes__lab_result_text", result_attributes[:lab_result_text])
    @browser.type("morbidity_event_new_lab_attributes__interpretation", result_attributes[:lab_interpretation])
    @browser.select("morbidity_event_new_lab_attributes__specimen_source_id", result_attributes[:lab_specimen_source])
    @browser.type("morbidity_event_new_lab_attributes__collection_date", result_attributes[:lab_collection_date])
    @browser.type("morbidity_event_new_lab_attributes__lab_test_date", result_attributes[:lab_test_date])
    @browser.select("morbidity_event_new_lab_attributes__specimen_sent_to_uphl_yn_id", "label=#{result_attributes[:sent_to_uphl]}")
  end

  def add_treatment(browser, result_attributes, index = 1)
    click_core_tab(browser, CLINICAL)
    browser.click("link=Add a treatment") unless index == 1
    sleep(1)
    type_field_by_order(@browser, "treatment", 0, result_attributes[:treatment])
    browser.select('morbidity_event_active_patient__new_treatment_attributes__treatment_given_yn_id', result_attributes[:treatment_given])
    browser.type('morbidity_event_active_patient__new_treatment_attributes__treatment_date', result_attributes[:treatment_date])
  end

  def save_contact_event(browser)
    browser.click "save_and_exit_btn"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Contact event was successfully created.") or
        browser.is_text_present("Contact event was successfully updated."))
  end
  
  def add_place(browser, place_attributes, index = 1)
    click_core_tab(browser, EPI)
    browser.click "link=New Place Exposure"
    sleep(1)
    browser.type("//div[@class='place_exposure'][#{index}]//input[contains(@id, 'name')]", place_attributes[:name])
  end

  def save_place_event(browser)
    browser.click "save_and_exit_btn"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Place event was successfully created.") or
        browser.is_text_present("Place event was successfully updated."))
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
  
  def navigate_to_disease_admin(browser)
    browser.open "/trisano/cmrs"
    click_nav_admin(browser)
    browser.click("link=Diseases")
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Diseases"))
  end
  
  def navigate_to_export_admin(browser)
    browser.open "/trisano/cmrs"
    click_nav_admin(browser)
    browser.click("link=CDC Export Configuration")
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Export Columns"))
  end

  def create_disease(browser, disease_attributes)
    modify_disease(browser, disease_attributes)
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Disease was successfully created."))
  end

  def modify_disease(browser, disease_attributes)
    browser.type("disease_disease_name", disease_attributes[:disease_name]) if disease_attributes[:disease_name]
    browser.type("disease_cdc_code", disease_attributes[:cdc_code]) if disease_attributes[:cdc_code]
    browser.click("disease_active") if disease_attributes[:disease_active]
    browser.type("disease_contact_lead_in", disease_attributes[:contact_lead_in]) if disease_attributes[:contact_lead_in]
    browser.type("disease_place_lead_in", disease_attributes[:place_lead_in]) if disease_attributes[:place_lead_in]
    browser.type("disease_treatment_lead_in", disease_attributes[:treatment_lead_in]) if disease_attributes[:treatment_lead_in]
    if disease_attributes[:external_codes]
      disease_attributes[:external_codes].each do |id, msg|
        browser.send(msg, [id])
      end
    end
    browser.click("disease_submit")
  end    

  def click_edit_disease(browser, disease_name)
    disease_id = get_resource_id(browser, disease_name)
    browser.click("//a[contains(@href, 'diseases/#{disease_id}/edit')]")
    browser.wait_for_page_to_load($load_time)
  end

  def edit_disease(browser, disease_name, disease_attributes)
    click_edit_disease(browser, disease_name)
    modify_disease(browser, disease_attributes)
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Disease was successfully updated."))
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
  
  def click_build_form(browser, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/trisano/forms/builder/" + id.to_s + "')]"
      browser.wait_for_page_to_load "30000"
      return 0
    else
      return -1
    end
  end
  
  def click_form_export(browser, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/trisano/forms/" + id.to_s + "/export')]"
      return true
    else
      return false
    end
  end
  
  def click_push_form(browser, name)
    id = get_resource_id(browser, name)
    if id > 0 
      browser.click "//a[contains(@href, '/trisano/forms/" + id.to_s + "/push')]"
      browser.wait_for_page_to_load "30000"
      return true
    else
      return false
    end
  end
 
  def create_simplest_cmr(browser, last_name)
    click_nav_new_cmr(browser)
    browser.type "morbidity_event_active_patient__person_last_name", last_name
    yield browser if block_given?
    return save_cmr(browser)
  end

  def create_basic_investigatable_cmr(browser, last_name, disease_label, jurisdiction_label)
    click_nav_new_cmr(browser)
    browser.type "morbidity_event_active_patient__person_last_name", last_name
    browser.type("morbidity_event_active_patient__address_street_number", "22")
    browser.type("morbidity_event_active_patient__address_street_name", "Happy St.")
    click_core_tab(browser, CLINICAL)
    browser.select "morbidity_event_disease_disease_id", "label=#{disease_label}"
    click_core_tab(browser, ADMIN)
    browser.select "morbidity_event_active_jurisdiction_secondary_entity_id", "label=#{jurisdiction_label}"
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
  
  def create_new_form_and_go_to_builder(browser, form_name, disease_label, jurisdiction_label, type='Morbidity event')
    browser.open "/trisano/cmrs"
    browser.click "link=FORMS"
    browser.wait_for_page_to_load($load_time)
    browser.click "//input[@value='Create new form']"
    browser.wait_for_page_to_load($load_time)
    browser.type "form_name", form_name
    browser.select "form_event_type", "label=#{type}"
    if disease_label.respond_to?(:each)
      disease_label.each { |label| browser.click(label.tr(" ", "_")) }
    else
      browser.click(disease_label.tr(" ", "_"))
    end
    browser.select "form_jurisdiction_id", "label=#{jurisdiction_label}"
    browser.click "form_submit"    
    browser.wait_for_page_to_load($load_time)
    if browser.is_text_present("Form was successfully created.") != true 
      return(false)
    end
    sleep 3
    browser.click "link=Detail"
    browser.wait_for_page_to_load($load_time)
    return browser.is_text_present("Publish") 
  end
  
  def edit_form_and_go_to_builder(browser, form_attributes ={})
    browser.type "form_name", form_attributes[:form_name] unless form_attributes[:form_name].nil?
    browser.select "form_event_type", "label=#{form_attributes[:event_type]}" unless form_attributes[:event_type].nil?
    #puts "label=#{form_attributes[:event_type]}" unless form_attributes[:event_type].nil?
    unless form_attributes[:disease].nil?
      if form_attributes[:disease].respond_to?(:each)
        form_attributes[:disease].each { |label| browser.click(label.tr(" ", "_")) }
      else
        browser.click( form_attributes[:disease].tr(" ", "_"))
      end
    end
    
    browser.select "form_jurisdiction_id", "label=#{ form_attributes[:jurisdiction]}" unless form_attributes[:jurisdiction].nil?
    browser.click "form_submit"    
    browser.wait_for_page_to_load($load_time)
    if browser.is_text_present("Form was successfully updated.") != true 
      return(false)
    end
    browser.click "link=Detail"
   
    browser.wait_for_page_to_load($load_time)
    return browser.is_element_present("publish_btn")
    #return browser.is_text_present("Form Builder") 
  end
  
  # Must be called from the builder view
  def open_form_builder_library_admin(browser)
    browser.click("open-library-admin")
    wait_for_element_present("library-admin-container")
    return(browser.is_text_present("Library Administration"))
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
    browser.click("view_element_submit")
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
    browser.click("section_element_submit")
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
    browser.click "follow_up_element_submit"
    wait_for_element_not_present("new-follow-up-form", browser)
  end
  
  
  def edit_core_follow_up(browser, element_name, condition, core_label)
    element_id = get_form_element_id(browser, element_name, FOLLOW_UP_ID_PREFIX)
    browser.click("edit-follow-up-#{element_id}")
    wait_for_element_present("edit-follow-up-form", browser)
    browser.type "model_auto_completer_tf", condition
    sleep 1 # Give the type ahead a second to breath, otherwise the edit doesn't stick
    browser.select "follow_up_element_core_path", "label=#{core_label}"
    browser.click "follow_up_element_submit"
    wait_for_element_not_present("edit-follow-up-form", browser)
  end
  
  def edit_follow_up(browser, element_name, condition)
    element_id = get_form_element_id(browser, element_name, FOLLOW_UP_ID_PREFIX)
    browser.click("edit-follow-up-#{element_id}")
    wait_for_element_present("edit-follow-up-form", browser)
    browser.type "follow_up_element_condition", condition
    browser.click "follow_up_element_submit"
    wait_for_element_not_present("edit-follow-up-form", browser)
  end
  
  # This method is pretty weak. Always does a three-value value set. Could be beefed up to take a variable number of values.
  def add_value_set_to_question(browser, question_text, value_set_name, value_one, value_two, value_three)
    element_id = get_form_element_id(browser, question_text, QUESTION_ID_PREFIX)
    browser.click("add-value-set-#{element_id}")
    wait_for_element_present("new-value-set-form", browser)
    browser.type "value_set_element_name", value_set_name
    browser.click "link=Add a value"
    browser.click "link=Add a value"
    browser.click "link=Add a value"
    wait_for_element_present("value_set_element_new_value_element_attributes__name")
    browser.type "value_set_element_new_value_element_attributes__name", value_one
    browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][1]", value_two
    browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][2]", value_three
    browser.click "value_set_element_submit"
    wait_for_element_not_present("new-value-set-form")
    browser.is_text_present(value_set_name).should be_true
    
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
    browser.click("core_view_element_submit")
    wait_for_element_not_present("new-core-view-form", browser)
  end
  
  def add_core_field_config(browser, core_field_name)
    browser.click("add-core-field")
    wait_for_element_present("new_core_field_element", browser)
    browser.select("core_field_element_core_path", "label=#{core_field_name}")
    browser.click("core_field_element_submit")
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
    browser.click "question_element_submit"    
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
    browser.click "follow_up_element_submit"
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
    browser.click "follow_up_element_submit"
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
      result = wordlist[rand(319)]
      raise if result.nil?
    rescue Exception => ex
      result = wordlist[rand(319)]
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
