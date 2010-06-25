module Trisano
  module TrisanoPerinatalHepB
    module Controllers
      module MorbidityEventsController
        reloadable!
        hook! "MorbidityEventsController"

        class << self
          def included(base)
            base.before_filter :render_perinatal_hep_b_fields, :only => [:new, :edit, :update, :create]
            base.before_filter :render_perinatal_hep_b_show,   :only => [:show]
          end
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

