module Trisano
  module TrisanoPerinatalHepB
    module Controllers
      module MorbidityEventsController
        reloadable!
        hook! "MorbidityEventsController"

        class << self
          def included(base)
            base.before_filter :can_update?, :only => [:edit, :update, :destroy, :soft_delete, :event_type, :remove_expected_delivery_facility]
            base.before_filter :render_perinatal_hep_b_fields, :only => [:new, :edit, :update, :create]
            base.before_filter :render_perinatal_hep_b_show,   :only => [:show]
          end
        end

        def auto_complete_for_expected_delivery_facilities
          place_name = params[:morbidity_event][:expected_delivery_facility_attributes][:place_entity_attributes][:place_attributes][:name]
          places_by_name_and_types(place_name, Place.expected_delivery_type_codes)
          render :partial => 'events/delivery_facility_choices'
        end

        def remove_expected_delivery_facility
          @event = MorbidityEvent.find(params[:id], :include => :expected_delivery_facility)
          @event.remove_expected_delivery_data
          render(:template => 'events/update_expected_delivery_facility')
        end

        def update_expected_delivery_facility
          @event = MorbidityEvent.find(params[:id], :include => {:expected_delivery_facility => { :place_entity => [:telephones, :place] } })
          @place_entity = PlaceEntity.find(params[:place_entity_id])
          if @event.expected_delivery_facility
            @event.expected_delivery_facility.update_attributes!(:place_entity => @place_entity)
          else
            @event.build_expected_delivery_facility(:place_entity => @place_entity).save!
          end
          render(:template => 'events/update_expected_delivery_facility')
        end

        def auto_complete_for_actual_delivery_facilities
          place_name = params[:morbidity_event][:actual_delivery_facility_attributes][:place_entity_attributes][:place_attributes][:name]
          places_by_name_and_types(place_name, Place.actual_delivery_type_codes)
          render :partial => 'events/delivery_facility_choices'
        end

        def remove_actual_delivery_facility
          @event = MorbidityEvent.find(params[:id], :include => :actual_delivery_facility)
          @event.remove_actual_delivery_data
          render(:template => 'events/update_actual_delivery_facility')
        end

        def update_actual_delivery_facility
          @event = MorbidityEvent.find(params[:id], :include => {:actual_delivery_facility => { :place_entity => [:telephones, :place] } })
          @place_entity = PlaceEntity.find(params[:place_entity_id])
          if @event.actual_delivery_facility
            @event.actual_delivery_facility.update_attributes!(:place_entity => @place_entity)
          else
            @event.build_actual_delivery_facility(:place_entity => @place_entity).save!
          end
          render(:template => 'events/update_actual_delivery_facility')
        end

        private

        def render_perinatal_hep_b_fields
          after_core_partials[due_date_core_field] << {
            :partial => 'events/perinatal_hep_b_fields'
          }
          after_core_partials[event_name_core_field] << {
            :partial => 'events/state_manager_edit'
          }
        end

        def render_perinatal_hep_b_show
          after_core_partials[due_date_core_field] << {
            :partial => 'events/perinatal_hep_b_show'
          }
          after_core_partials[event_name_core_field] << {
            :partial => 'events/state_manager_show'
          }
        end

        def event_name_core_field
          "morbidity_event[event_name]"
        end

        def due_date_core_field
          "morbidity_event[interested_party][risk_factor][pregnancy_due_date]"
        end

      end
    end
  end
end

