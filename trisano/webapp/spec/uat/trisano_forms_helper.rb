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
  
end
