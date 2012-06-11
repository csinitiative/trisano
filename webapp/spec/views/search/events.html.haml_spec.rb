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

require File.dirname(__FILE__) + '/../../spec_helper'

# DEBT: only testing the availability of fields, not the layout
describe "search/events.html.haml" do
  include Trisano::HTML::Matchers

  def assert_in_search_group(&block)
    response.should have_tag("div[class='search_group clearfix']", &block)
  end

  def assert_in_other_criteria(&block)
    assert_in_search_group do |div|
      div.should have_tag("div[id='all_other_criteria'][style*='display: none']", &block)
    end
  end

  def workflow_mock(description)
    mock(description) do
      stubs(:description).returns(description)
      stubs(:workflow_state).returns(description.downcase.gsub(' ', '_'))
    end
  end

  def jurisdiction(short_name)
    create_jurisdiction_entity(:place_attributes => {:short_name => short_name}).place
  end

  def default_assigns
    assigns[:jurisdictions] ||= [jurisdiction('Summit County')]
    assigns[:counties] ||= [Factory.create(:county, :code_description => 'Bear River')]
    assigns[:genders] ||=  [Factory.create(:gender, :code_description => 'Male'),
                          Factory.create(:gender, :code_description => 'Female')]
    assigns[:diseases] ||= [Factory.create(:disease, :disease_name => 'Diphtheria')]
    assigns[:workflow_states] ||= [workflow_mock('Assigned to Investigator')]
    assigns[:event_types] ||= [['Morbidity Event','MorbidityEvent']]
    assigns[:investigators] ||= [Factory.create(:user, :first_name => 'Jon', :last_name => 'Dough')]
  end

  def do_render(options={})
    default_assigns
    options.each { |k, v| assigns[k] = v }
    render "search/events.html.haml"
  end

  it "renders search fields if user can view events" do
    do_render
    assert_in_search_group
  end

  it "doesn't render search fields if user can't view events" do
    do_render(:jurisdictions => nil)
    response.should_not have_tag("div[class='search_group clearfix']")
  end

  it "renders flash errors" do
    flash[:error] = "Ooops. Something went wrong"
    do_render
    response.should have_tag("span[style='color:red']", "Ooops. Something went wrong")
  end

  it "renders name search fields" do
    do_render
    assert_in_search_group do |group|
      group.should have_tag("div[id='name_criteria']") do |div|
        div.should have_tag("input[name='name']")
        div.should have_tag("input[name='sw_first_name']")
        div.should have_tag("input[name='sw_last_name']")
      end
    end
  end

  it "renders all other criteria hidden" do
    do_render
    assert_in_other_criteria
  end

  it "renders demographic search fields" do
    do_render
    assert_in_other_criteria do |div|
      div.should have_tag("div[id='demographic_criteria']") do |demo|
        demo.should have_tag("input[name='city']")
        demo.should have_tag("select[name='county']") do |county|
          county.should have_blank_option
          county.should have_option(:text => "Bear River", :selected => false)
        end
        demo.should have_tag("select[name='gender']") do |gender|
          gender.should have_blank_option
          gender.should have_option(:text => 'Male')
          gender.should have_option(:text => 'Female')
        end
        demo.should have_tag("input[name='birth_date']")
      end
    end
  end

  it "county from search criteria is selected by default" do
    county = Factory.create(:county, :code_description => 'Some County')
    assigns[:counties] = [county]
    params[:county] = county.id.to_s
    do_render
    assert_in_other_criteria do |div|
      div.should have_tag("select[name='county']") do |county|
        county.should have_option(:text => 'Some County', :selected => true)
      end
    end
  end

  it "renders clinical search fields" do
    do_render
    assert_in_other_criteria do |div|
      div.should have_tag("div[id='clinical_criteria']") do |clinical|
        clinical.should have_tag('div.horiz') do |horiz|
          horiz.should have_tag('label', 'Diseases')
          horiz.should have_tag('div div') do |panel|
            panel.should have_labeled_check_box('Diphtheria')
          end
        end
        clinical.should have_tag('div.horiz') do |horiz|
          horiz.should have_tag("label[for='pregnant_id']")
          horiz.should have_tag('select#pregnant_id') do |preg|
            preg.should have_blank_option
            preg.should have_option(:text => 'Yes')
            preg.should have_option(:text => 'No')
          end
        end
      end
    end
  end

  it "renders event search fields" do
    params[:workflow_state] = 'assigned_to_investigator'
    params[:event_type] = 'MorbidityEvent'
    params[:sent_to_cdc] = 'false'
    j = jurisdiction('Boys Town')
    assigns[:jurisdictions] = [j]
    params[:jurisdiction_ids] = [j.entity_id]
    do_render
    assert_in_other_criteria do |div|
      div.should have_tag("div[id='event_criteria']") do |event|
        event.should have_tag('div.horiz') do |horiz|
          horiz.should have_tag('label[for=?]', 'workflow_state')
          horiz.should have_tag("select#workflow_state") do |state|
            state.should have_blank_option
            state.should have_option(:text => 'Assigned to Investigator',
                                     :selected => true)
          end
        end
        event.should have_tag('div.horiz') do |horiz|
          horiz.should have_tag("label[for=?]", 'event_type')
          horiz.should have_tag("select#event_type") do |et|
            et.should have_blank_option
            et.should have_option(:text => 'Morbidity Event',
                                  :selected => true)
          end
        end
        event.should have_tag('div.horiz') do |horiz|
          horiz.should have_tag('label[for=?]', 'sent_to_cdc')
          horiz.should have_tag("select#sent_to_cdc") do |cdc|
            cdc.should have_blank_option
            cdc.should have_option(:text => 'Yes')
            cdc.should have_option(:text => 'No',
                                   :selected => true)
          end
        end
        event.should have_tag("div.vert") do |vert|
          vert.should have_tag("label[for=?]", 'entered_on_start')
          vert.should have_tag("input#entered_on_start")
          vert.should have_tag("input#entered_on_end")
        end
        event.should have_tag("div.horiz") do |horiz|
          horiz.should have_tag("label[for=?]", 'record_number')
          horiz.should have_tag("input#record_number")
        end
        event.should have_tag("div.vert") do |vert|
          vert.should have_tag("label[for=?]", 'jurisdiction_ids')
          vert.should have_tag("select#jurisdiction_ids") do |j|
            j.should_not have_blank_option
            j.should have_option(:text => 'Boys Town',
                                 :selected => true)
          end
        end
        event.should have_tag("div.horiz") do |horiz|
          horiz.should have_tag("label[for=?]", 'state_case_status_ids')
          horiz.should have_tag("select#state_case_status_ids") do |scs|
            scs.should_not have_blank_option
            scs.should have_option(:text => 'Confirmed')
          end
        end
        event.should have_tag("div.horiz") do |horiz|
          horiz.should have_tag("label[for=?]", 'lhd_case_status_ids')
          horiz.should have_tag("select#lhd_case_status_ids") do |lcs|
            lcs.should_not have_blank_option
            lcs.should have_option(:text => 'Confirmed')
          end
        end
        event.should have_tag("div.horiz") do |horiz|
          horiz.should have_tag("label[for=?]", 'investigator_ids')
          horiz.should have_tag("select#investigator_ids") do |i|
            i.should_not have_blank_option
            i.should have_option(:text => 'Jon Dough')
          end
        end
      end
    end
  end

  it "renders epi search fields" do
    do_render
    assert_in_other_criteria do |div|
      div.should have_tag("div[id='epi_reporting_criteria']") do |epi|
        epi.should have_tag("label[for=?]", "other_data_1")
        epi.should have_tag("input#other_data_1")
        epi.should have_tag("label[for=?]", "other_data_2")
        epi.should have_tag("input#other_data_2")
        epi.should have_tag("label[for=?]", "first_reported_PH_date_start")
        epi.should have_tag("input#first_reported_PH_date_start")
        epi.should have_tag("input#first_reported_PH_date_end")
      end
    end
  end

  it "renders search buttons" do
    do_render
    response.should have_tag("input#submit_query")
    response.should have_tag("input[value='Start Over']")
  end

end
