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
  before_filter :can_update?, :only => [:hospitalization_facilities, :patient_telephones]


  def patient_telephones
    Person.transaction do
      event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
      raise "No event params posted" if event_params.nil?


      patient_tele_attr = event_params[:interested_party_attributes][:person_entity_attributes][:telephones_attributes]
      raise "More than one patient telephone submitted: #{patient_tele_attr.inspect}" if patient_tele_attr.each_value.count != 1
      # Because we only ever submit one repeater, it's ok to just take the first
      patient_tele_attr = patient_tele_attr.each_value.first
      
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
          new_answer_attributes = event_params.delete(:new_repeater_answer)
          unless new_answer_attributes.nil?
            raise "A repeater object is required to create a new answer." if @patient_telephone.nil?
            new_answer_attributes.each do |answer_attributes|


              answer_attributes[:repeater_form_object_id] = @patient_telephone.id
              answer_attributes[:repeater_form_object_type] = @patient_telephone.class.name
              answer_attributes[:event_id] = @event.id
              a = Answer.create(answer_attributes)
              raise "Unable to create Answer for #{@patient_telephone.inspect}:\n #{a.errors.inspect}" unless a.valid?

            end #new_anwer_attributes.each

          end #new_answer_attributes.nil


        end # if repeater_dependent destroyed == 1 
      end #if saved_successfully

      # Must include respond_to inside transaction to have scope for
      # event_saved_successfully
      respond_to do |format|
        if saved_successfully
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




  def hospitalization_facilities
    HospitalsParticipation.transaction do
      event_params = params[:assessment_event] || params[:morbidity_event] || params[:contact_event]
      raise "No event params posted" if event_params.nil?


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





          # We've either created a new repeater or
          # determined which existing one to use.
          # time to create an answer for it.
          new_answer_attributes = event_params.delete(:new_repeater_answer)
          unless new_answer_attributes.nil?
            raise "A repeater object is required to create a new answer." if @hospitalization_facility.nil?
            new_answer_attributes.each do |answer_attributes|


              answer_attributes[:repeater_form_object_id] = @hospitalization_facility.id
              answer_attributes[:repeater_form_object_type] = @hospitalization_facility.class.name
              answer_attributes[:event_id] = @event.id
              a = Answer.create(answer_attributes)
              raise "Unable to create Answer for #{@hospitalization_facility.inspect}:\n #{a.errors.inspect}" unless a.valid?

            end #new_anwer_attributes.each

          end #new_answer_attributes.nil


        end # if repeater_dependent destroyed == 1 
      else
        @hospitalization_facility = @event.hospitalization_facilities.detect { |hf| !hf.valid? }
      end #if event_saved_successfully

      # Must include respond_to inside transaction to have scope for
      # event_saved_successfully
      respond_to do |format|
        if event_saved_successfully
          redis.delete_matched("views/events/#{@event.id}/edit/clinical_tab")
          format.js   { render :partial => "events/ajax_hospital", :status => :ok }
        else
          format.js   { render :partial => "events/ajax_hospital", :status => :unprocessable_entity }
        end
      end    
    end #transaction
  end #hospitalization_facilities
end #class
