module Trisano
  module TrisanoPerinatalHepB
    module Controllers
      module ContactEventsController
        reloadable!
        hook! "ContactEventsController"

        class << self
          def included(base)
            base.before_filter :render_perinatal_hep_b_fields, :only => [:new, :edit, :update, :create]
            base.before_filter :render_perinatal_hep_b_show,   :only => [:show]
          end
        end

        private

        def render_perinatal_hep_b_fields
          core_replacement_partial[treatments_core_field] = { :partial => 'events/perinatal_hep_b_treatment_fields' } if replace_fields?
        end

        def render_perinatal_hep_b_show
          core_replacement_partial[treatments_core_field] = { :partial => 'events/perinatal_hep_b_treatment_show' } if replace_fields?
        end

        def replace_fields?
          core_field = CoreField.event_fields(@event)[treatments_core_field]
          if core_field
            association = core_field.disease_association(@event.try(:disease_event).try(:disease))
            association && association.replaced
          end
        end

        def treatments_core_field
          "contact_event[treatments]"
        end

      end
    end
  end
end

