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

module TrisanoPlacesHelper

  def add_place(browser, attributes, index = 1)
    click_core_tab(browser, EPI)
    browser.click "link=Add a place exposure"
    sleep(1)
    browser.type("//div[@id='place_child_events']//li[@class='place_exposure'][#{index}]//input[contains(@id, 'name')]", attributes[:name])
    browser.click("//div[@id='place_child_events']//li[@class='place_exposure'][#{index}]//input[contains(@id, '_place_attributes_place_type_#{attributes[:place_type]}')]") if attributes[:place_type]
  end

  def save_place_event(browser)
    browser.click "save_and_exit_btn"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Place event was successfully created.") or
        browser.is_text_present("Place event was successfully updated."))
  end

  def edit_place(browser)
    browser.click "link=Edit Place"
    browser.wait_for_page_to_load($load_time)
    return(browser.is_text_present("Edit Place Event"))
  end

  def add_place_info(browser, attributes)
    browser.type("//div[@id='place_tab']//div[@id='place_form']//input[contains(@id, '_street_number')]", attributes[:street_number]) if attributes[:street_number]

    # Fill in the rest...

  end

  def remove_place_exposure(browser, index=1)
    browser.click("//div[@id='place_child_events']//li[@class='existing_place'][#{index}]//input[contains(@id, '_destroy')]")
  end
  
end
