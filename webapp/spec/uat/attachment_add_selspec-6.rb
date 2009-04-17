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

# $dont_kill_browser = true

describe 'Adding an attachment to a morbidity event' do
  
  before(:all) do
    @cmr_last_name = get_random_word << " att-uat"
    @disease = get_random_disease
  end

  after(:all) do
    @cmr_last_name = nil
    @disease = nil
  end

  it "should create a basic CMR" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it "should add an attachment from show mode" do

    # The following was just copied from the form import/export test. We need to get square on our
    # intentions with using Selenium in this way before investing in getting this running.
    # 
    # The rest relies on browser profile changes that we need to get dialed in. Works if you uncomment and
    # also use the alternate @browser initialization in spec_helper.
    #
    #    click_form_export(@browser, @form_name).should be_true
    #    sleep 2
    #    File.exist?("#{$trisano_download_file_url}#{@form_name.downcase.sub(" ", "_")}.zip").should be_true
    #
    #    @browser.type("form_import", "#{$trisano_download_file_url}#{@form_name.downcase.sub(" ", "_")}.zip")
    #    @browser.click("//input[@value='Upload']")
    #    @browser.wait_for_page_to_load($load_time)
    #    @browser.click "link=Form Builder"
    #    @browser.wait_for_page_to_load($load_time)
    #
  end
    
end
