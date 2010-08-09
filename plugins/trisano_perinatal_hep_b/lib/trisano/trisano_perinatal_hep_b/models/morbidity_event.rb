# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

module Trisano
  module TrisanoPerinatalHepB
    module Models
      module MorbidityEvent
        hook! "MorbidityEvent"
        reloadable!

        class << self
          def included(base)
            base.before_save :generate_state_manager_tasks
          end
        end

        private

        def generate_state_manager_tasks
          return unless ::DiseaseSpecificCallback.callbacks(self.disease_event.try(:disease)).include?('state_manager_expected_delivery_date_task')
          if self.state_manager
            if self.interested_party.try(:risk_factor).try(:pregnancy_due_date_changed?)
              task = tasks.find(:first, :conditions => { :task_tracking_key => 'state_manager_expected_delivery_date_task' })
              if task
                task.destroy
              end
              unless self.interested_party.risk_factor.pregnancy_due_date.nil?
                tasks.build(:task_tracking_key => 'state_manager_expected_delivery_date_task',
                            :user => self.state_manager,
                            :due_date => self.interested_party.risk_factor.pregnancy_due_date,
                            :name => I18n.t(:expected_delivery_date_entered,
                                            :scope => :perinatal_hep_b_management,
                                            :loacle => I18n.default_locale))
              end
            end
          end
        end

      end
    end
  end
end
