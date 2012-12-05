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

class HumanEventsController < EventsController
  before_filter :can_update?, :only => [:treatments, :patient_email_addresses, :patient_telephones, :hospitalization_facilities]

  def treatments
    event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
    raise "No event params posted" if event_params.nil?


    repeater_attr = event_params[:interested_party_attributes][:treatments_attributes]
    raise "More than one repeater submitted: #{repeater_attr.inspect}" if repeater_attr.each_value.count != 1
    # Because we only ever submit one repeater, it's ok to just take the first
    repeater_attr = repeater_attr.each_value.first

    @treatment = @event.interested_party.treatments.build(repeater_attr)

    respond_to do |format|
      if @treatment.save
        redis.delete_matched("views/events/#{@event.id}/show/clinical_tab")
        redis.delete_matched("views/events/#{@event.id}/edit/clinical_tab")
        format.js   { render :partial => "events/repeater_treatment_form", :status => :ok }
      else
        format.js   { render :partial => "events/repeater_treatment_form", :status => :unprocessable_entity }
      end
    end    

  end

  def patient_email_addresses
    event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
    raise "No event params posted" if event_params.nil?


    repeater_attr = event_params[:interested_party_attributes][:person_entity_attributes][:email_addresses_attributes]
    raise "More than one repeater submitted: #{repeater_attr.inspect}" if repeater_attr.each_value.count != 1
    # Because we only ever submit one repeater, it's ok to just take the first
    repeater_attr = repeater_attr.each_value.first

    @patient_email_address = @event.interested_party.person_entity.email_addresses.build(repeater_attr)

    respond_to do |format|
      if @patient_email_address.save
        redis.delete_matched("views/events/#{@event.id}/edit/demographic_tab")
        redis.delete_matched("views/events/#{@event.id}/show/demographic_tab")
        format.js   { render :partial => "people/repeater_patient_email_form", :status => :ok }
      else
        format.js   { render :partial => "people/repeater_patient_email_form", :status => :unprocessable_entity }
      end
    end    
  end #patient email_address

  def patient_telephones
    event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
    raise "No event params posted" if event_params.nil?


    patient_tele_attr = event_params[:interested_party_attributes][:person_entity_attributes][:telephones_attributes]
    raise "More than one patient telephone submitted: #{patient_tele_attr.inspect}" if patient_tele_attr.each_value.count != 1
    # Because we only ever submit one repeater, it's ok to just take the first
    patient_tele_attr = patient_tele_attr.each_value.first

    @patient_telephone = @event.interested_party.person_entity.telephones.build(patient_tele_attr)

    respond_to do |format|
      if @patient_telephone.save
        redis.delete_matched("views/events/#{@event.id}/edit/demographic_tab")
        redis.delete_matched("views/events/#{@event.id}/show/demographic_tab")
        format.js   { render :partial => "people/ajax_patient_phone_form", :status => :ok }
      else
        format.js   { render :partial => "people/ajax_patient_phone_form", :status => :unprocessable_entity }
      end
    end    
  end #patient telephone


  def hospitalization_facilities
    event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
    raise "No event params posted" if event_params.nil?

    repeater = event_params[:hospitalization_facilities_attributes]
    raise "More than one hospitalization facility submitted: #{repeater.inspect}" if repeater.each_value.count != 1
    # Because we only ever submit one repeater, it's ok to just take the first
    repeater = repeater.each_value.first

    @hospitalization_facility = @event.hospitalization_facilities.build(repeater)

    respond_to do |format|
      if @hospitalization_facility.save
        redis.delete_matched("views/events/#{@event.id}/show/clinical_tab")
        redis.delete_matched("views/events/#{@event.id}/edit/clinical_tab")
        format.js   { render :partial => "events/ajax_hospital", :status => :ok }
      else
        format.js   { render :partial => "events/ajax_hospital", :status => :unprocessable_entity }
      end
    end    
  end #hospitalization_facilities
end #class
