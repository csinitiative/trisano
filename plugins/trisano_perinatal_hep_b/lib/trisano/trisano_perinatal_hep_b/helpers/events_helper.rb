module Trisano
  module TrisanoPerinatalHepB
    module Helpers
      module EventsHelper
        reloadable!
        extend_helper :events_helper

        def state_managers_for_select
          User.state_managers.map do |manager|
            [manager.best_name, manager.id]
          end
        end

      end
    end
  end
end
