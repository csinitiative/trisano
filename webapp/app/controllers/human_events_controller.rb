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
  before_filter :can_update?, :only => [:hospitalization_facilities]
  def hospitalization_facilities
    HospitalsParticipation.transaction do
      event_params = params[:assessment_event] || params[:morbidity_event]


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
   
        repeater_dependent_attributes = event_params[:hospitalization_facilities_attributes]
        raise "More than one hospitalization faclity submitted: #{repeater_dependent_attributes.inspect}" if repeater_dependent_attributes.each_value.count != 1
        # Because we only ever submit one repeater, it's ok to just take the first
        repeater_dependent_attributes = repeater_dependent_attributes.each_value.first






        if repeater_dependent_attributes[:_destroy] == "1"
          # record was destroyed by @event.save

          # Nothing to do when deleting a parent repeater (hospitlization facilities).
          # The answer handled by the the cascading :dependent => :destroy from
          # hospitalization_facility > hospitals_participation > answer


        else # else from if repeater_dependent_attributes[:_destory] == "1"
          # saving a new/existing record

          if repeater_id = repeater_dependent_attributes[:id]
            # existing repeater
            @hospitalization_facility = HospitalizationFacility.find(repeater_id)


          else # from repeater_dependent_attributes[:id]

            # new repeater


            # new repeater created, must determine which what was created:
            @hospitalization_facility = post_save_repeater_parents - pre_save_repeater_parents
            if @hospitalization_facility == [] 
              # no repeater created, create one!
              @hospitalization_facility = @event.hospitalization_facilities.build
            elsif @hospitalization_facility.length != 1
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



          end # if repeater_dependent_attributes[:id] (new or existing record?)





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
