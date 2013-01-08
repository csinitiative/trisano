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

module TrisanoContactsHelper

  def show_contact(browser)
    browser.click "link=Show"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Person Information") and
        browser.is_text_present("Street number"))
  end

  def edit_contact(browser)
    browser.click "link=Edit"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Person Information") and
        browser.is_text_present("Street number"))
  end

  def add_contact(browser, contact_attributes, index = 1)
    click_core_tab(browser, CONTACTS)
    browser.click "link=Add a contact"
    sleep(1)
    browser.type("//li[@class='contact'][#{index}]//input[contains(@id, 'last_name')]", contact_attributes[:last_name])
    browser.type("//li[@class='contact'][#{index}]//input[contains(@id, 'first_name')]", contact_attributes[:first_name])
    browser.select("//li[@class='contact'][#{index}]//select[contains(@id, 'disposition')]", "label=#{contact_attributes[:disposition]}")
    
    browser.type("//li[@class='contact'][#{index}]//input[contains(@id, '_area_code')]", contact_attributes[:area_code])
    browser.type("//li[@class='contact'][#{index}]//input[contains(@id, '_phone_number')]", contact_attributes[:phone_number])
    browser.type("//li[@class='contact'][#{index}]//input[contains(@id, '_extension')]", contact_attributes[:extension])
  end

  def save_contact_event(browser)
    browser.click "save_and_exit_btn"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Contact event was successfully created.") or
        browser.is_text_present("Contact event was successfully updated."))
  end

  # To navigate to a contact from the morbidity event
  # TODO: Add multiples support
  def edit_contact_event(browser)
    browser.click "link=Edit Contact"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Edit Contact Event"))
  end

  def remove_contact(browser, index=1)
    browser.click("//div[@id='contact_child_events']//li[@class='contact'][#{index}]//input[contains(@id, '_destroy')]")
  end
  
end
