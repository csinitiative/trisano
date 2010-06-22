module Trisano
  module TrisanoPerinatalHepB
    module Controllers
      module MorbidityEventsController
        reloadable!
        hook! "MorbidityEventsController"

        class << self
          def included(base)
            base.before_filter :render_perinatal_hep_b_fields, :only => [:new, :edit, :update, :create]
          end
        end

        private

        def render_perinatal_hep_b_fields
          key = "morbidity_event[interested_party][risk_factor][pregnancy_due_date]"
          after_core_partials[key] << {
            :partial => 'events/perinatal_hep_b_fields'
          }
        end

      end
    end
  end
end

