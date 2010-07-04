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
          @event.expected_delivery_facility.update_attributes(:place_entity => nil, :expected_delivery_facilities_participation => nil)
          render(:template => 'events/update_expected_delivery_facility')
        end

        def update_expected_delivery_facility
          @event = MorbidityEvent.find(params[:id], :include => :expected_delivery_facility)
          @event.expected_delivery_facility.update_attributes(:secondary_entity_id => params[:place_entity_id])
          render(:template => 'events/update_expected_delivery_facility')
        end

        private

        def render_perinatal_hep_b_fields
          after_core_partials[core_field_key] << {
            :partial => 'events/perinatal_hep_b_fields'
          }
        end

        def render_perinatal_hep_b_show
          after_core_partials[core_field_key] << {
            :partial => 'events/perinatal_hep_b_show'
          }
        end

        def core_field_key
          "morbidity_event[interested_party][risk_factor][pregnancy_due_date]"
        end

      end
    end
  end
end

