module Trisano
  module TrisanoPerinatalHepB
    module Models
      module HumanEvent
        hook! "HumanEvent"
        reloadable!

        class << self
          def included(base)
            base.has_one :expected_delivery_facility,
              :foreign_key => "event_id",
              :order => 'created_at ASC',
              :dependent => :destroy
          end
        end
      end
    end
  end
end
