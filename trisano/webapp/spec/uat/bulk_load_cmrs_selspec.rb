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
describe "Bulk loading CMR's for CDC export" do
  before(:each) do
    #put any setup tasks here
  end
  (1..20).each do |i|
    it "describe what this thing should do here" do
      @browser.open "/trisano/forms"
      @browser.click "link=NEW CMR"
      @browser.wait_for_page_to_load "30000"
      @browser.type "morbidity_event_active_patient__person_last_name", get_unique_name(2)
      @browser.select "morbidity_event_active_patient__address_state_id", "label=Utah"
      @browser.select "morbidity_event_active_patient__address_county_id", "label=Duchesne"
      @browser.type "morbidity_event_active_patient__address_postal_code", "46062"
      @browser.click "//img[@alt='Calendar']"
      @browser.click "//tr[2]/td[3]/div"
      @browser.type "morbidity_event_active_patient__person_birth_date", "January 6, 1946"
      @browser.click "//ul[@id='tabs']/li[2]/a/em"
      @browser.select "morbidity_event_disease_hospitalized_id", "label=Yes"
      @browser.select "morbidity_event_disease_disease_id", "label=#{get_random_disease}"
      @browser.select "morbidity_event_disease_died_id", "label=Yes"
      @browser.select "morbidity_event_active_patient__participations_risk_factor_pregnant_id", "label=Yes"
      @browser.click "//ul[@id='tabs']/li[6]/a/em"
      @browser.click "//div[@id='reporting_agencies']/span[9]/img"
      @browser.click "//tr[2]/td[6]/div"
      @browser.click "//ul[@id='tabs']/li[7]/a/em"
      @browser.click "//ul[@id='tabs']/li[9]/a/em"
      @browser.select "morbidity_event_lhd_case_status_id", "label=Confirmed"
      @browser.select "morbidity_event_state_case_status_id", "label=Confirmed"
      @browser.type "morbidity_event_outbreak_name", "Random"
      @browser.select "morbidity_event_outbreak_associated_id", "label=Yes"
      @browser.click "save_and_continue_btn"
      @browser.wait_for_page_to_load "30000"
      puts i
    end
  end
end
