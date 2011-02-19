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

        def generate_state_manager_tasks
          return unless ::DiseaseSpecificCallback.callbacks(self.disease_event.try(:disease)).include?('state_manager_expected_delivery_date_task')
          return unless state_manager

          if expected_due_date_updated? or state_manager_id_changed?
            remove_expected_due_date_tasks
            generate_expected_due_date_task unless expected_due_date_blank?
          end

          if expected_delivery_facility_data_updated?
            generate_expected_due_date_and_delivery_facility_task unless expected_delivery_facility_data_incomplete?
          end
        end


        def expected_due_date_updated?
          self.interested_party.try(:risk_factor).try(:pregnancy_due_date_changed?)
        end

        def expected_due_date_blank?
          self.interested_party.try(:risk_factor).try(:pregnancy_due_date).blank?
        end

        def expected_delivery_facility_data_updated?
          expected_due_date_updated? or
            state_manager_id_changed? or
            self.expected_delivery_facility.try(:secondary_entity_id_changed?) or
            self.expected_delivery_facility.try(:place_entity).try(:new_record?)
        end

        def expected_delivery_facility_data_incomplete?
          self.expected_delivery_facility.try(:place_entity).try(:place).nil? || expected_due_date_blank?
        end

        def remove_expected_due_date_tasks
          tasks.find(:all, :conditions => { :task_tracking_key => 'state_manager_expected_delivery_date_task' }).each do |task|
            task.destroy
          end
        end

        def generate_expected_due_date_task
          tasks.build(:task_tracking_key => 'state_manager_expected_delivery_date_task',
                      :user => self.state_manager,
                      :due_date => Date.today,
                      :name => I18n.t(:expected_delivery_date_entered,
                                      :scope => :perinatal_hep_b_management,
                                      :locale => I18n.default_locale))
        end

        def generate_expected_due_date_and_delivery_facility_task
          tasks.build(:user => self.state_manager,
                      :due_date => Date.today,
                      :name => I18n.t(:expected_delivery_facility_data_entered,
                                      :scope => :perinatal_hep_b_management,
                                      :locale => I18n.default_locale))
        end

      end
    end
  end
end
