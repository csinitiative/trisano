# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

module TrisanoFormsHelper

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

  def click_build_form_by_id(browser, id)
    browser.click "//a[contains(@href, '/trisano/forms/builder/" + id.to_s + "')]"
    browser.wait_for_page_to_load "30000"
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

  def click_deactivate_form(browser, name)
    id = get_resource_id(browser, name)
    if id > 0
      browser.click "//a[contains(@href, '/trisano/forms/" + id.to_s + "/deactivate')]"
      browser.wait_for_page_to_load "30000"
      return true
    else
      return false
    end
  end

  def create_new_form_and_go_to_builder(browser, form_name, disease_label, jurisdiction_label, type='Morbidity Event', short_name=nil)
    click_nav_forms(@browser).should be_true
    browser.click "//input[@value='Create New Form']"
    browser.wait_for_page_to_load($load_time)
    browser.type "form_name", form_name
    browser.type "form_short_name", short_name || form_name
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
    browser.click "link=Builder"
    browser.wait_for_page_to_load($load_time)
    return browser.is_text_present("Publish")
  end

  def edit_form_and_go_to_builder(browser, form_attributes ={})
    browser.type "form_name", form_attributes[:form_name] unless form_attributes[:form_name].nil?
    browser.type "form_short_name", form_attributes[:short_name] unless form_attributes[:short_name].nil?
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
    browser.click "link=Builder"

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
  def add_question_to_view(browser, element_name, question_attributes = {}, expect_error=false)
    return add_question_to_element(browser, element_name, VIEW_ID_PREFIX, question_attributes, expect_error)
  end

  # Takes the name of the section to which the question should be added and the question's attributes.
  def add_question_to_section(browser, element_name, question_attributes = {}, expect_error=false)
    return add_question_to_element(browser, element_name, SECTION_ID_PREFIX, question_attributes, expect_error)
  end

  # Takes the name of the follow-up container to which the question should be added and the question's attributes.
  def add_question_to_follow_up(browser, element_name, question_attributes = {}, expect_error=false)
    #    puts 'element_name: ' + element_name
    #    puts 'FOLLOW_UP_ID_PREFIX: ' + FOLLOW_UP_ID_PREFIX
    #    puts question_attributes.to_s
    return add_question_to_element(browser, element_name, FOLLOW_UP_ID_PREFIX, question_attributes, expect_error)
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

  def edit_question_by_id(browser, question_element_id, question_attributes={}, expect_error=false)
    browser.click("edit-question-#{question_element_id}")
    wait_for_element_present("edit-question-form", browser)
    fill_in_question_attributes(browser, question_attributes, { :mode => :edit })
    browser.click "//input[contains(@id, 'edit_question_submit')]"

    unless expect_error
      wait_for_element_not_present("edit-question-form", browser)
    else
      sleep 1
    end

    if browser.is_text_present(question_attributes[:question_text])
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
    sleep(1)
    "OK"
    # Debt: Find something to do an assertion off of
  end

  def add_question_from_library(browser, question_text)
    browser.click "link=Add question to tab"
    wait_for_element_present("new-question-form")
    browser.click("link=Show all groups")
    sleep(2) # Debt: If this UI sticks, add something to key off of instead of using this sleep
    browser.click "link=#{question_text}"
    sleep(2) # Debt: If this UI sticks, add something to key off of instead of using this sleep
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
    click_publish_button(browser)
    browser.wait_for_page_to_load($publish_time)
    return(browser.is_text_present("Form was successfully published"))
  end

  def publish_form_failure(browser=@browser)
    click_publish_button(browser).should be_true
    browser.wait_for_ajax
    browser.is_text_present("Short name is already being used by another active form.") and browser.is_text_present("Unable to publish the form")
  end

  def click_publish_button(browser)
    browser.click '//input[@value="Publish"]'
    browser.wait_for_ajax
    true
  end

  def add_form_to_event(browser, form_name)
    browser.click("link=Add/Remove forms for this event")
    browser.wait_for_page_to_load($load_time)
    html_source = browser.get_html_source
    name_position = html_source.index(form_name)
    id_start_position = html_source.index("forms_to_add_", name_position) + "forms_to_add_".size
    id_end_position = html_source.index("\"", id_start_position)-1
    id = html_source[id_start_position..id_end_position]
    browser.click("forms_to_add_#{id}")
    browser.click("add_forms")
    browser.wait_for_page_to_load($load_time)
    return browser.is_text_present("The list of forms in use was successfully updated.")
  end

end
