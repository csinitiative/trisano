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
    browser.type("//div[@class='contact'][#{index}]//input[contains(@id, 'last_name')]", contact_attributes[:last_name])
    browser.type("//div[@class='contact'][#{index}]//input[contains(@id, 'first_name')]", contact_attributes[:first_name])
    browser.select("//div[@class='contact'][#{index}]//select[contains(@id, 'disposition')]", "label=#{contact_attributes[:disposition]}")
  end
  
end
