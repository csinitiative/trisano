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
  before_filter :can_update?, :only => [:hospitalization_facilities, :patient_telephones, :patient_email_addresses]

  def patient_email_addresses
    EmailAddress.transaction do
      event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
      raise "No event params posted" if event_params.nil?


      repeater_attr = event_params[:interested_party_attributes][:person_entity_attributes][:email_addresses_attributes]
      raise "More than one repeater submitted: #{repeater_attr.inspect}" if repeater_attr.each_value.count != 1
      # Because we only ever submit one repeater, it's ok to just take the first
      repeater_attr = repeater_attr.each_value.first


      # Remove repeater attributes because they shouldn't be handled by the regular model actions
      # Will raise an error if posted, see app/model/event.rb
      new_text_box_answer_attributes = event_params.delete(:new_repeater_answer)
      new_checkbox_answer_attributes = event_params.delete(:new_repeater_checkboxes)
      new_radio_button_answer_attributes = event_params.delete(:new_repeater_radio_buttons)
      
      # Need to include the entity to attach the email to
      repeater_attr.merge!({:owner_id => @event.interested_party.person_entity.id.to_s, :owner_type => "Entity"})


      @patient_email_address = EmailAddress.new(repeater_attr)
      if saved_successfully = @patient_email_address.save


        # PARAMS PARSING
        # ==============
   
        if repeater_attr[:_destroy] == "1"
          # record was destroyed by @event.save


        else # else from if patient_tele_attr[:_destory] == "1"
          # saving a new/existing record

          @event.interested_party.person_entity.email_addresses.reload


          # We've either created a new repeater or
          # determined which existing one to use.
          # time to create an answer for it.
          answer_save_results = []
          answer_save_results << create_answers(:text, new_text_box_answer_attributes, @patient_email_address, @event)
          answer_save_results << create_answers(:checkbox, new_checkbox_answer_attributes, @patient_email_address, @event)
          answer_save_results << create_answers(:radio_button, new_radio_button_answer_attributes, @patient_email_address, @event) 

          created_answers_successfully = !answer_save_results.include?(false)


        end # if repeater_dependent destroyed == 1 
      end #if saved_successfully

      # Must include respond_to inside transaction to have scope for
      # event_saved_successfully
      respond_to do |format|
        if saved_successfully and created_answers_successfully
          redis.delete_matched("views/events/#{@event.id}/edit/demographic_tab")
          redis.delete_matched("views/events/#{@event.id}/show/demographic_tab")
          format.js   { render :partial => "people/repeater_patient_email_form", :status => :ok }
        else
          logger.error @patient_email_address.errors.inspect
          format.js   { render :partial => "people/repeater_patient_email_form", :status => :unprocessable_entity }
        end
      end    
    end #transaction
  end #patient email_address

  def patient_telephones
    Person.transaction do
      event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
      raise "No event params posted" if event_params.nil?


      patient_tele_attr = event_params[:interested_party_attributes][:person_entity_attributes][:telephones_attributes]
      raise "More than one patient telephone submitted: #{patient_tele_attr.inspect}" if patient_tele_attr.each_value.count != 1
      # Because we only ever submit one repeater, it's ok to just take the first
      patient_tele_attr = patient_tele_attr.each_value.first


      # Remove repeater attributes because they shouldn't be handled by the regular model actions
      # Will raise an error if posted, see app/model/event.rb
      new_text_box_answer_attributes = event_params.delete(:new_repeater_answer)
      new_checkbox_answer_attributes = event_params.delete(:new_repeater_checkboxes)
      new_radio_button_answer_attributes = event_params.delete(:new_repeater_radio_buttons)
      
      # Need to include the entity to attach the phone to
      patient_tele_attr.merge!({:entity_id => @event.interested_party.person_entity.id.to_s})


      @patient_telephone = Telephone.new(patient_tele_attr)
      if saved_successfully = @patient_telephone.save


        # PARAMS PARSING
        # ==============
   
        if patient_tele_attr[:_destroy] == "1"
          # record was destroyed by @event.save


        else # else from if patient_tele_attr[:_destory] == "1"
          # saving a new/existing record

          @event.interested_party.person_entity.telephones.reload


          # We've either created a new repeater or
          # determined which existing one to use.
          # time to create an answer for it.
          created_answers_successfully = []
          created_answers_successfully << create_answers(:text, new_text_box_answer_attributes, @patient_telephone, @event)
          created_answers_successfully << create_answers(:checkbox, new_checkbox_answer_attributes, @patient_telephone, @event)
          created_answers_successfully << create_answers(:radio_button, new_radio_button_answer_attributes, @patient_telephone, @event) 

          created_answers_successfully = !answer_save_results.include?(false)


        end # if repeater_dependent destroyed == 1 
      end #if saved_successfully

      # Must include respond_to inside transaction to have scope for
      # event_saved_successfully
      respond_to do |format|
        if saved_successfully and created_answers_successfully
          redis.delete_matched("views/events/#{@event.id}/edit/demographic_tab")
          redis.delete_matched("views/events/#{@event.id}/show/demographic_tab")
          format.js   { render :partial => "people/ajax_patient_phone_form", :status => :ok }
        else
          logger.error @patient_telephone.errors.inspect
          format.js   { render :partial => "people/ajax_patient_phone_form", :status => :unprocessable_entity }
        end
      end    
    end #transaction
  end #hospitalization_facilities


  def save_radio_button_answer(event, repeater_object, key, value)
    answer = event.answers.build(
      :question_id => key,
      :radio_button_answer => value[:radio_button_answer],
      :export_conversion_value_id => value[:export_conversion_value_id],
      :code => value[:code],
      :repeater_form_object_id => repeater_object.id,
      :repeater_form_object_type => repeater_object.class.name
    )
    answer.save
  end

  def save_checkbox_answer(event, repeater_object, key, value)
    answer = event.answers.build(
      :question_id => key,
      :check_box_answer => value[:check_box_answer],
      :code => value[:code],
      :repeater_form_object_id => repeater_object.id,
      :repeater_form_object_type => repeater_object.class.name
    )
    answer.save
  end

  def save_text_answer(event, repeater_object, answer_attr)
    answer = event.answers.build(answer_attr)         
    answer.repeater_form_object_id = repeater_object.id
    answer.repeater_form_object_type = repeater_object.class.name
    answer.save
  end


  def create_answers(answer_type, attributes, repeater_object, event) 
    return true if attributes.nil?
    raise "Invalid answer type provided" unless %w(radio_button checkbox text).include?(answer_type.to_s)
    raise "A repeater object is required to create a new answer." if repeater_object.nil?

    answer_save_results = []

    # constructs the appropriate method name
    method_name = "save_#{answer_type}_answer"

    if attributes.is_a?(Array)
      attributes.each do |answer_attr|
        answer_save_results << method(method_name).call(event, repeater_object, answer_attr)
      end
    elsif attributes.is_a?(Hash)
      attributes.each do |key, value|
        answer_save_results << method(method_name).call(event, repeater_object, key, value)
      end
    end


    # let's us know if all text boxes answers were saved correctly
    !answer_save_results.include?(false)
  end


  def hospitalization_facilities
    HospitalsParticipation.transaction do
      event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
      raise "No event params posted" if event_params.nil?

      # Remove repeater attributes because they shouldn't be handled by the regular model actions
      # Will raise an error if posted, see app/model/event.rb
      new_text_box_answer_attributes = event_params.delete(:new_repeater_answer)
      new_checkbox_answer_attributes = event_params.delete(:new_repeater_checkboxes)
      new_radio_button_answer_attributes = event_params.delete(:new_repeater_radio_buttons)

      # Must take a clone here, otherwise we get a reference
      # and lose the "point in time" record
      pre_save_repeater_parents = @event.hospitalization_facilities.clone


      # Existing answers won't be processed
      # here, they'll be processed by Event#answers=
      # If they've been created correctly here, then they'll be associated with the appropiate
      # repeater object.
      @event.update_from_params(event_params)
      if event_saved_successfully = @event.save

        post_save_repeater_parents = @event.hospitalization_facilities.reload




        # PARAMS PARSING
        # ==============
   
        hospitalization_facility_attr = event_params[:hospitalization_facilities_attributes]
        raise "More than one hospitalization faclity submitted: #{hospitalization_facility_attr.inspect}" if hospitalization_facility_attr.each_value.count != 1
        # Because we only ever submit one repeater, it's ok to just take the first
        hospitalization_facility_attr = hospitalization_facility_attr.each_value.first






        if hospitalization_facility_attr[:_destroy] == "1"
          # record was destroyed by @event.save

          # Nothing to do when deleting a parent repeater (hospitlization facilities).
          # The answer handled by the the cascading :dependent => :destroy from
          # hospitalization_facility > hospitals_participation > answer


        else # else from if hospitalization_facility_attr[:_destory] == "1"
          # saving a new/existing record

          if repeater_id = hospitalization_facility_attr[:id]
            # existing repeater
            @hospitalization_facility = HospitalizationFacility.find(repeater_id)


          else # from hospitalization_facility_attr[:id]

            # new repeater


            # new repeater created, must determine which what was created:
            @hospitalization_facility = post_save_repeater_parents - pre_save_repeater_parents
            if @hospitalization_facility.length != 1
              raise "More than one hospitalization facilities created:\n
                     post_save_repeaters: #{post_save_repeater_parents.inspect}\n
                     pre_save_repeaters: #{pre_save_repeater_parents.inspect}\n\n
                     If more than one hospitalization facilities created, we cannot determine which repeater to save."
            else
              @hospitalization_facility = @hospitalization_facility.first
            end #@hospitalization_facility == [], create one
          
              



            if @hospitalization_facility.new_record?
              raise "Cannot save HospitalizationFacility: #{@hospitalization_facility.errors.inspect}" unless @hospitalization_facility.save
              @event.hospitalization_facilities.reload
            end



          end # if hospitalization_facility_attr[:id] (new or existing record?)




          # Now that we have our new/existing hospitalization facility
          # we can save the repeater answers
          answer_save_results = []
          answer_save_results << create_answers(:text, new_text_box_answer_attributes, @hospitalization_facility, @event)
          answer_save_results << create_answers(:checkbox, new_checkbox_answer_attributes, @hospitalization_facility, @event)
          answer_save_results << create_answers(:radio_button, new_radio_button_answer_attributes, @hospitalization_facility, @event) 


          created_answers_successfully = !answer_save_results.include?(false)


        end # if repeater_dependent destroyed == 1 
      else
        @hospitalization_facility = @event.hospitalization_facilities.detect { |hf| !hf.valid? }
      end #if event_saved_successfully

      # Must include respond_to inside transaction to have scope for
      # event_saved_successfully
      respond_to do |format|
        if event_saved_successfully and created_answers_successfully
          redis.delete_matched("views/events/#{@event.id}/show/clinical_tab")
          format.js   { render :partial => "events/ajax_hospital", :status => :ok }
        else
          format.js   { render :partial => "events/ajax_hospital", :status => :unprocessable_entity }
        end
      end    
    end #transaction
  end #hospitalization_facilities
end #class
