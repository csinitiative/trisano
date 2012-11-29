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
  OUTBREAK = "Outbreak"

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
    PLACE => "place_tab",
    OUTBREAK => "outbreak_tab"
  }

  def wait_for_element_present(name, browser=nil)
    browser = @browser.nil? ? browser : @browser
    !60.times{ return true if (browser.is_element_present(name) rescue false); sleep 1 }
  end

  def wait_for_element_not_present(name, browser=nil)
    browser = @browser.nil? ? browser : @browser
    !60.times{ return false unless (browser.is_element_present(name) rescue true); sleep 1 }
  end

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
    wordlist = YAML.load_file(File.join(RAILS_ROOT, 'db', 'defaults', 'diseases.yml')).collect { |k,v| v[:diseases] }.flatten.collect{ |d| d[:disease_name] }.uniq
    wordlist[rand(wordlist.size)]
  end

  def get_random_jurisdiction()
    wordlist = ["Out of State","Weber-Morgan Health Department","Wasatch County Health Department","Utah State","Utah County Health Department","TriCounty Health Department","Tooele County Health Department","Summit County Public Health Department","Southwest Utah Public Health Department","Southeastern Utah District Health Department","Salt Lake Valley Health Department","Davis County Health Department","Central Utah Public Health Department","Bear River Health Department","Unassigned"]
    wordlist[rand(wordlist.size)]
  end

  def get_random_jurisdiction_by_short_name()
    wordlist = ["Unassigned", "Bear River", "Central Utah",  "Davis County", "Salt Lake Valley",  "Southeastern Utah", "Southwest Utah",  "Summit County", "Tooele County",  "TriCounty", "Utah County",  "Utah State", "Wasatch County", "Weber-Morgan", "Out of State"]
    wordlist[rand(wordlist.size)]
  end

  #
  # General navigation and controls
  #

  def click_logo(browser)
    browser.click 'logo'
    browser.wait_for_page_to_load($load_time)
  end

  def click_nav_new_cmr(browser)
    browser.open "/trisano/cmrs/new"
    browser.wait_for_page_to_load($load_time)
    return (browser.is_text_present("New Morbidity Event") and
        browser.is_text_present("New CMR") and
        browser.is_element_present("link=< Back to list") and
        browser.is_element_present("disable_tabs"))
  end

  def click_nav_cmrs(browser)
    browser.click 'link=EVENTS'
    browser.wait_for_page_to_load($load_time)
    return (browser.is_text_present("List Morbidity Events") and
        browser.is_element_present("link=EVENTS"))
  end

  def click_nav_search(browser)
    browser.click 'link=SEARCH'
    browser.wait_for_page_to_load($load_time)
    return browser.is_text_present("Event Search")
  end

  def click_nav_forms(browser)
    click_nav_admin(browser)
    browser.click 'link=Manage Forms'
    browser.wait_for_page_to_load($load_time)
    return (browser.is_text_present("Form Information") and
        browser.is_text_present("Diseases") and
        browser.is_text_present("Jurisdiction") and
        browser.is_text_present("Event Type") and
        browser.is_element_present("//input[@value='Upload']") and
        browser.is_element_present("//input[@id='form_import']") and
        browser.is_element_present("//input[@value='Create New Form']")
    )
  end

  def click_nav_admin(browser)
    unless browser.is_element_present("link=ADMIN")
      @browser.open "/trisano/events"
      @browser.wait_for_page_to_load($load_time)
    end
    browser.click 'link=ADMIN'
    browser.wait_for_page_to_load($load_time)
    browser.is_text_present("Admin Dashboard")
  end

  def edit_cmr(browser)
    browser.click "link=Edit"
    browser.wait_for_page_to_load($load_time)
    return(browser.get_html_source.include?("Person Information") and
        browser.get_html_source.include?("Street number"))
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
    return true
  end

  def save_cmr(browser)
    save_and_exit(browser)
  end

  def save_and_continue(browser)
    browser.click "save_and_continue_btn"
    browser.wait_for_page_to_load($load_time)
    return true
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

    wait_for_element_present("//div[contains(@id, 'printing_controls')]")
    browser.click "print_all"
    browser.get_eval("selenium.browserbot.findElement(\"//form[contains(@action, 'print')]\").target='doit';")
    browser.open_window("", "doit");
    browser.click "print_btn"
    browser.wait_for_pop_up("doit", $load_time)
    browser.select_window("doit")
    return(browser.get_html_source.include?('Confidential Case Report') && browser.get_html_source.include?('Printed'))
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
    return(browser.is_text_present("Name Criteria"))
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
      browser.click "//a[contains(@href, '/trisano/" + resource + "/" + id.to_s + "/edit')]"
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
    first_reported_to_ph_date browser, Date.today
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
    first_reported_to_ph_date browser, Date.today
    click_core_tab(browser, ADMIN)
    browser.select "morbidity_event_jurisdiction_attributes_secondary_entity_id", "label=#{jurisdiction_label}" if jurisdiction_label
    yield browser if block_given?
    return save_cmr(browser)
  end

  def answer_investigator_question(browser, question_text, answer, html_source=nil)
    answer_id = get_investigator_answer_id(browser, question_text, html_source)
    begin
      browser.type("#{INVESTIGATOR_ANSWER_ID_PREFIX}#{answer_id}", answer) == "OK"
    rescue
      return false
    end
    return true
  end

  def watch_for_core_field_spinner(core_field, browser=@browser, &proc)
    css_selector = %Q{img[id$="#{core_field}_spinner"]}
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
      browser.click("//input[contains(@id, 'investigator_answer_#{answer_id}') and @value='#{answer}']") == "OK"
    rescue
      return false
    end
    return true
  end

  def answer_radio_investigator_question(browser, question_text, answer)
    answer_id = get_investigator_click_answer_id(browser, question_text)
    begin
      browser.click("//input[contains(@id, 'investigator_answer_#{answer_id}') and @value='#{answer}']") == "OK"
    rescue
      return false
    end
    return true
  end

  def switch_user(browser, user_id)
    current_user = @browser.get_selected_label("user_id")
    if current_user != user_id
      browser.select("user_id", "label=#{user_id}")
      browser.wait_for_page_to_load
      return browser.is_text_present("#{user_id}:")
    end
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
  def get_unique_name(words=1)
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
    browser.get_html_source.scan(/#{text}/).size
  end

  def assert_tab_contains_question(browser, tab_name, question_text, html_source=nil)
    html_source = browser.get_html_source if html_source.nil?
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
      "morbidity_event_active_patient__new_treatment_attributes__treatment_name" => NedssHelper.get_unique_name(1),
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
      "morbidity_event_new_lab_attributes__specimen_sent_to_state_id" => "Yes",
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

  def enter_note(browser, note_text, options={:is_admin => false})
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

  def change_cmr_view(browser, attributes)
    @browser.click "link=Change View"
    attributes[:diseases].each do |disease|
      @browser.add_selection("//div[@id='change_view']//select[@id='diseases_selector']", "label=#{disease}")
    end if attributes[:diseases]
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    # Fill in the rest...
  end
  #
  # Demographic Tab
  #

  def add_demographic_info(browser, attributes)
    click_core_tab(browser, DEMOGRAPHICS)
    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_last_name')]", attributes[:last_name]) if attributes[:last_name]
    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_first_name')]", attributes[:first_name]) if attributes[:first_name]
    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_middle_name')]", attributes[:middle_name]) if attributes[:middle_name]

    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_street_number')]", attributes[:street_number]) if attributes[:street_number]

    # //div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_street_name')]
    # //div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_unit_number')]
    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_city')]", attributes[:city]) if attributes[:city]

    browser.select("//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_county_id')]", "label=#{attributes[:county]}") if attributes[:county]
    browser.select("//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_state_id')]", "label=#{attributes[:state]}") if attributes[:state]
    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_postal_code')]", attributes[:postal_code]) if attributes[:postal_code]


    browser.type("//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_approximate_age_no_birthday')]", attributes[:approximate_age_no_birthday]) if attributes[:approximate_age_no_birthday]

    browser.select("//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_birth_gender_id')]", "label=#{attributes[:birth_gender]}") if attributes[:birth_gender]

    # //div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_ethnicity_id')]

    # Fill in the rest...

  end

  #
  # Clinical Tab
  #

  def add_clinical_info(browser, attributes)
    click_core_tab(browser, CLINICAL)
    browser.select("//div[@id='clinical_tab']//select[contains(@id, '_disease_id')]", "label=#{attributes[:disease]}") if attributes[:disease]
    browser.select("//div[@id='clinical_tab']//select[contains(@id, '_died_id')]", "label=#{attributes[:died]}") if attributes[:died]
    browser.select("//div[@id='clinical_tab']//select[contains(@id, '_pregnant_id')]", "label=#{attributes[:pregnant]}") if attributes[:pregnant]

    # Fill in the rest...

  end

  def add_diagnostic_facility(browser, attributes)
    click_core_tab(browser, CLINICAL)
    browser.click "link=Add a diagnostic facility"
    sleep(1)
    browser.type("//div[@id='diagnostic_facilities']//div[@class='diagnostic']//input[contains(@id, '_place_entity_attributes_place_attributes_name')]", attributes[:name])
    browser.click("//div[@id='diagnostic_facilities']//div[@class='diagnostic']//input[contains(@id, '_place_attributes_place_type_#{attributes[:place_type]}')]") if attributes[:place_type]
  end

  def remove_diagnostic_facility(browser, index=0, event_type="morbidity_event")
    browser.click("css=##{event_type}_diagnostic_facilities_attributes_#{index}__destroy")
  end

  def add_hospital(browser, attributes, index = 1)
    click_core_tab(browser, CLINICAL)
    browser.click "link=Add a Hospitalization Facility" unless index == 1
    sleep(1)
    browser.select("//div[@id='hospitalization_facilities']//div[@class='hospital'][#{index}]//select[contains(@id, '_secondary_entity_id')]", "label=#{attributes[:name]}")
    browser.type("//div[@id='hospitalization_facilities']//div[@class='hospital'][#{index}]//input[contains(@id, '_admission_date')]", attributes[:admission_date]) if attributes[:admission_date]
    browser.type("//div[@id='hospitalization_facilities']//div[@class='hospital'][#{index}]//input[contains(@id, '_discharge_date')]", attributes[:discharge_date]) if attributes[:discharge_date]
    browser.type("//div[@id='hospitalization_facilities']//div[@class='hospital'][#{index}]//input[contains(@id, '_medical_record_number')]", attributes[:medical_record_number]) if attributes[:medical_record_number]
  end

  def add_email(browser, attributes, index = 1)
    click_core_tab(browser, DEMOGRAPHICS)
    browser.click "link=Add an Email Address" unless index == 1
    field_id = @browser.get_attribute "//div[@id='email_addresses']//div[@class='email'][#{index}]//label[contains(text(), 'Email address')]/@for"
    browser.type(field_id, attributes[:email])
  end

  def add_telephone(browser, attributes, index = 1)
    click_core_tab(browser, DEMOGRAPHICS)
    browser.click "link=Add a Telephone" unless index == 1
    browser.select("//div[@id='telephones']//div[@class='phone'][#{index}]//select[contains(@id, '_entity_location_type_id')]", "label=#{attributes[:type]}")
    browser.type("//div[@id='telephones']//div[@class='phone'][#{index}]//input[contains(@id, '_area_code')]", attributes["area code"])
    browser.type("//div[@id='telephones']//div[@class='phone'][#{index}]//input[contains(@id, '_phone_number')]", attributes[:number])
  end

  def remove_hospital(browser, index = 1)
    browser.click("//div[@id='hospitalization_facilities']//div[@class='hospital'][#{index}]//input[contains(@id, '_destroy')]")
  end

  def add_treatment(browser, attributes, index = 1)
    click_core_tab(browser, CLINICAL)
    browser.click("link=Add a Treatment") unless index == 1
    sleep(1)
    browser.select("//div[@class='treatment'][#{index}]//select", attributes[:treatment_given])
    browser.type("//div[@class='treatment'][#{index}]//input[contains(@name, '[treatment_name]')]",    attributes[:treatment_name])
    browser.type("//div[@class='treatment'][#{index}]//input[contains(@name, 'treatment_date')]", attributes[:treatment_date])
  end

  def add_clinician(browser, attributes, index = 1)
    click_core_tab(browser, CLINICAL)
    browser.click("link=Add a Clinician") unless index == 1
    sleep(1)
    browser.type("//div[@id='clinicians']//div[@class='clinician'][#{index}]//input[contains(@id, '_last_name')]", attributes[:last_name])
    browser.type("//div[@id='clinicians']//div[@class='clinician'][#{index}]//input[contains(@id, '_first_name')]", attributes[:first_name]) if attributes[:first_name]
    browser.type("//div[@id='clinicians']//div[@class='clinician'][#{index}]//input[contains(@id, '_middle_name')]", attributes[:middle_name]) if attributes[:middle_name]
    browser.select("//div[@id='clinicians']//div[@class='clinician'][#{index}]//select[contains(@id, '_entity_location_type_id')]", "label=#{attributes[:phone_type]}") if attributes[:phone_type]
    browser.type("//div[@id='clinicians']//div[@class='clinician'][#{index}]//input[contains(@id, '_area_code')]", attributes[:area_code]) if attributes[:area_code]
    browser.type("//div[@id='clinicians']//div[@class='clinician'][#{index}]//input[contains(@id, '_phone_number')]", attributes[:phone_number]) if attributes[:phone_number]
    browser.type("//div[@id='clinicians']//div[@class='clinician'][#{index}]//input[contains(@id, '_extension')]", attributes[:extension]) if attributes[:extension]
  end

  def remove_clinician(browser, index=1)
    browser.click("//div[@id='clinicians']//div[@class='existing_clinician'][#{index}]//input[contains(@id, '_destroy')]")
  end

  #
  # Lab Tab
  #

  def add_lab_result(browser, attributes, lab_index = 1, result_index = 1)
    click_core_tab(browser, LABORATORY)
    browser.click("link=Add a new lab result") unless lab_index == 1
    sleep(1)
    browser.select("//div[@id='labs']//div[@class='lab'][#{lab_index}]//select[contains(@id, '_secondary_entity_id')]", "label=#{attributes[:lab_name]}") if attributes[:lab_name]
    browser.type("//div[@id='labs']//div[@class='lab'][#{lab_index}]//div[@class='lab_result'][#{result_index}]//input[contains(@id, '_lab_result_text')]", attributes[:lab_result_text]) if attributes[:lab_result_text]
    browser.select("//div[@id='labs']//div[@class='lab'][#{lab_index}]//div[@class='lab_result'][#{result_index}]//select[contains(@id, '_interpretation_id')]", "label=#{attributes[:lab_interpretation]}") if attributes[:lab_interpretation]
    browser.select("//div[@id='labs']//div[@class='lab'][#{lab_index}]//div[@class='lab_result'][#{result_index}]//select[contains(@id, '_specimen_source_id')]", "label=#{attributes[:lab_specimen_source]}") if attributes[:lab_specimen_source]
    browser.type("//div[@id='labs']//div[@class='lab'][#{lab_index}]//div[@class='lab_result'][#{result_index}]//input[contains(@id, '_collection_date')]", attributes[:lab_collection_date]) if attributes[:lab_collection_date]
    browser.type("//div[@id='labs']//div[@class='lab'][#{lab_index}]//div[@class='lab_result'][#{result_index}]//input[contains(@id, '_lab_test_date')]", attributes[:lab_test_date]) if attributes[:lab_test_date]
    browser.select("//div[@id='labs']//div[@class='lab'][#{lab_index}]//div[@class='lab_result'][#{result_index}]//select[contains(@id, '_specimen_sent_to_state_id')]", "label=#{attributes[:sent_to_state]}") if attributes[:sent_to_state]
  end

  #
  # Encounters Tab
  #

  def add_encounter(browser, attributes, index = 1)
    click_core_tab(browser, ENCOUNTERS)
    sleep(1)
    browser.select("//div[@id='encounter_child_events']//div[@class='encounter'][#{index}]//select[contains(@id, '_user_id')]", "label=#{attributes[:user]}") if attributes[:user]
    browser.type("//div[@id='encounter_child_events']//div[@class='encounter'][#{index}]//input[contains(@id, '_encounter_date')]", attributes[:encounter_date]) if attributes[:encounter_date]
    browser.type("//div[@id='encounter_child_events']//div[@class='encounter'][#{index}]//textarea[contains(@id, '_description')]", attributes[:description]) if attributes[:description]
    browser.select("//div[@id='encounter_child_events']//div[@class='encounter'][#{index}]//select[contains(@id, '_location_type')]", "label=#{attributes[:location_type]}") if attributes[:location_type]
  end

  #
  # Reporting Tab
  #

  def add_reporting_info(browser, attributes)
    click_core_tab(browser, REPORTING)
    sleep(1)
    browser.type("//div[@id='reporting_agencies']//input[contains(@id, '_name')]", attributes[:name]) if attributes[:name]
    browser.click("//div[@id='reporting_agencies']//input[contains(@id, '_place_attributes_place_type_#{attributes[:place_type]}')]") if attributes[:place_type]

    browser.type("//div[@id='reporting_agencies']//input[contains(@id, '_area_code')]", attributes[:area_code]) if attributes[:area_code]
    browser.type("//div[@id='reporting_agencies']//input[contains(@id, '_phone_number')]", attributes[:phone_number]) if attributes[:phone_number]
    browser.type("//div[@id='reporting_agencies']//input[contains(@id, '_extension')]", attributes[:extension]) if attributes[:extension]

    browser.type("//div[@id='reporter']//input[contains(@id, '_last_name')]", attributes[:last_name]) if attributes[:last_name]
    browser.type("//div[@id='reporter']//input[contains(@id, '_last_name')]", attributes[:first_name]) if attributes[:first_name]
    browser.type("//div[@id='reporter']//input[contains(@id, '_area_code')]", attributes[:area_code]) if attributes[:area_code]
    browser.type("//div[@id='reporter']//input[contains(@id, '_phone_number')]", attributes[:phone_number]) if attributes[:phone_number]
    browser.type("//div[@id='reporter']//input[contains(@id, '_extension')]", attributes[:extension]) if attributes[:extension]

    browser.type("//div[@id='reported_dates']//input[contains(@id, '_clinician_date')]", attributes[:clinician_date]) if attributes[:clinician_date]
    browser.type("//div[@id='reported_dates']//input[contains(@id, '_PH_date')]", attributes[:PH_date]) if attributes[:PH_date]
  end

  def first_reported_to_ph_date(browser, date)
    click_core_tab browser, REPORTING
    sleep 1
    browser.type "//div[@id='reported_dates']//input[contains(@id, '_PH_date')]", date
  end

  def get_first_reported_ph(browser)
    click_core_tab browser, REPORTING
    sleep 1
    browser.get_value "//div[@id='reported_dates']//input[contains(@id, '_PH_date')]"
  end

  #
  # Admin Tab
  #

  def add_admin_info(browser, attributes)
    click_core_tab(browser, ADMIN)
    sleep(1)
    browser.select("//div[@id='administrative_tab']//select[contains(@id, '_event_status')]", "label=#{attributes[:event_status]}") if attributes[:event_status]
    browser.select("//div[@id='administrative_tab']//select[contains(@id, '_state_case_status_id')]", "label=#{attributes[:state_case_status]}") if attributes[:state_case_status]


    # Fill in the rest...

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

  def add_question_to_element(browser, element_name, element_id_prefix, question_attributes, expect_error=false)
    element_id = get_form_element_id(browser, element_name, element_id_prefix)
    add_question_attributes(browser, element_id, question_attributes, expect_error)
  end

  def add_question_to_core_field_config(browser, element_name, element_id_prefix, question_attributes)
    element_id = get_form_element_id_for_core_field(browser, element_name, element_id_prefix)
    add_question_attributes(browser, element_id, question_attributes)
  end

  def add_question_attributes(browser, element_id, question_attributes, expect_error=false)
    browser.click("add-question-#{element_id}")
    wait_for_element_present("new-question-form", browser)
    fill_in_question_attributes(browser, question_attributes)
    browser.click "//input[contains(@id, 'create_question_submit')]"

    unless expect_error
      wait_for_element_not_present("new-question-form", browser)
    else
      sleep 1
    end

    if browser.is_text_present(question_attributes[:question_text])
      return true
    else
      return false
    end
  end

  def fill_in_question_attributes(browser, question_attributes, options={ :mode => :add })
    browser.type("question_element_question_attributes_question_text", question_attributes[:question_text]) if question_attributes.include? :question_text
    browser.select("question_element_question_attributes_data_type", "label=#{question_attributes[:data_type]}") unless options[:mode] == :edit
    browser.select("question_element_export_column_id", "label=#{question_attributes[:export_column_id]}") if question_attributes.include? :export_column_id
    browser.select("question_element_question_attributes_style", "label=#{question_attributes[:style]}") if question_attributes.include? :style
    browser.click("question_element_is_active_#{question_attributes[:is_active].to_s}") if question_attributes.include? :is_active
    browser.type("question_element_question_attributes_short_name", question_attributes[:short_name])  if question_attributes.include? :short_name
    browser.type("question_element_question_attributes_help_text", question_attributes[:help_text]) if question_attributes[:help_text]
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

  def get_investigator_answer_id(browser, question_text, html_source=nil)
    html_source = browser.get_html_source if html_source.nil?
    question_position = html_source.index(question_text)
    id_start_position = html_source.index(INVESTIGATOR_ANSWER_ID_PREFIX, question_position) + 20
    id_end_position = html_source.index("\"", id_start_position) -1

    # This is a kluge that will go hunting for quot; if the id looks too big. Needed for reporting agency at least.
    quote_position = html_source.index("quot;", id_start_position)
    id_end_position = quote_position-3 if quote_position and (id_end_position-id_start_position > 21)

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
    browser.click('link=Builder')
    browser.wait_for_page_to_load($load_time)
    true
  end

  def assert_tooltip_exists(browser, tool_tip_text)
    browser.is_element_present("//img[contains(@src, 'help.png')]").should be_true
    browser.get_html_source.include?(tool_tip_text).should be_true
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
