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
      pre_save_repeaters = @event.hospitals_participations.clone


      # Existing answers won't be processed
      # here, they'll be processed by Event#answers=
      # If they've been created correctly here, then they'll be associated with the appropiate
      # repeater object.
      @event.update_from_params(event_params)
      if event_saved_successfully = @event.save

        post_save_repeater_parents = @event.hospitalization_facilities.reload
        post_save_repeaters = @event.hospitals_participations.reload




        # PARAMS PARSING
        # ==============
   
        repeater_dependent_attributes = event_params[:hospitalization_facilities_attributes]
        raise "More than one hospitalization faclity submitted: #{repeater_dependent_attributes.inspect}" if repeater_dependent_attributes.each_value.count != 1
        # Because we only ever submit one repeater, it's ok to just take the first
        repeater_dependent_attributes = repeater_dependent_attributes.each_value.first




        repeater_attributes = repeater_dependent_attributes[:hospitals_participation_attributes]
        raise "No hospitals participations attributes submitted: #{repeater_dependent_attributes.inspect}" if repeater_attributes.nil?


        # ==================
        


      


        if repeater_dependent_attributes[:_destroy] == "1"
          # record was destroyed by @event.save
          # must delete answer manually
          #raise "more than one answer submitted: #{event_params[:answers].inspect}" if event_params[:answers].each_key.count != 1
          #answer_id = event_params[:answers].each_key.first
          #Answer.find(answer_id).destroy if answer_id

          # Nothing to do when deleting a parent repeater (hospitlization facilities).
          # The answer handled by the the cascading :dependent => :destroy from
          # hospitalization_facility > hospitals_participation > answer


        else # else from if repeater_dependent_attributes[:_destory] == "1"
          # saving a new/existing record

          if repeater_id = repeater_attributes[:id]
            # existing repeater
            repeater_object = HospitalsParticipation.find(repeater_id)


          else # from repeater_attributes[:id]

            # new repeater


            # new repeater created, must determine which what was created:
            repeater_parent = post_save_repeater_parents - pre_save_repeater_parents
            repeater_object = post_save_repeaters - pre_save_repeaters


            if repeater_object == []
              # no repeater created, create one!

              # it's possible the parent was created without the repeater
              # by selecting a Health Facility, but providing no other information
              # Need to build and save a new one if neccissary
              if repeater_parent == [] 
                repeater_parent = @event.hospitalization_facilities.build
              elsif repeater_parent.length != 1
                raise "More than one hospitalization facilities created:\n
                       post_save_repeaters: #{post_save_repeater_parents.inspect}\n
                       pre_save_repeaters: #{pre_save_repeater_parents.inspect}\n\n
                       If more than one hospitalization facilities created, we cannot determine which repeater to save."
              else
                repeater_parent = repeater_parent.first
              end #repeater_parent == [], create one
            
                



              if repeater_parent.new_record?
                raise "Cannot save HospitalizationFacility: #{repeater_parent.errors.inspect}" unless repeater_parent.save
                @event.hospitalization_facilities.reload
              end

              # Create repeater
              repeater_object = HospitalsParticipation.new(:participation_id => repeater_parent.id)
              raise "Cannot save HospitalsParticipation: #{repeater_object.errors.inspect}" unless repeater_object.save
              @event.hospitals_participations.reload


            elsif repeater_object.length != 1
              # TODO: Possible race condition if multiple users are adding repeaters here.
              # Could add possibly add a JavaScript message to encourage the user to try again.
              raise "More than one hospitals participation created:\n
                     post_save_repeaters: #{post_save_repeaters.inspect}\n
                     pre_save_repeaters: #{pre_save_repeaters.inspect}\n\n
                     If more than one hospitals participation created, we cannot determine which repeater to save."
          
            else
              # We don't really want an array, just get the first element
              repeater_object = repeater_object.first

            end # repeater_obejct = [], create one




          end # if repeater_attributes[:id] (new or existing record?)





          # We've either created a new repeater or
          # determined which existing one to use.
          # time to create an answer for it.
          new_answer_attributes = event_params.delete(:new_repeater_answer)
          unless new_answer_attributes.nil?
            raise "A repeater object is required to create a new answer." if repeater_object.nil?
            new_answer_attributes.each do |answer_attributes|


              answer_attributes[:repeater_form_object_id] = repeater_object.id
              answer_attributes[:repeater_form_object_type] = repeater_object.class.name
              answer_attributes[:event_id] = @event.id
              a = Answer.create(answer_attributes)
              raise "Unable to create Answer for #{repeater_object.inspect}:\n #{a.errors.inspect}" unless a.valid?

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
