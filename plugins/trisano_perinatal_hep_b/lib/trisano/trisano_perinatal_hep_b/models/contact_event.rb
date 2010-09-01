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
      module ContactEvent
        hook! "ContactEvent"
        reloadable!

        class << self
          def included(base)

            base.class_eval do

              def before_save_with_p_hep_b_before_save
                before_save_without_p_hep_b_before_save
                assign_p_hep_b_tasks
              end

              private

              def assign_p_hep_b_tasks
                begin
                  assign_investigator_treatment_date_task if assign_investigator_treatment_task?(try(:disease).try(:disease))
                rescue Exception => ex
                  log_task_assignment_error(ex)
                end
              end

              def assign_investigator_treatment_task?(disease)
                (!disease.nil? &&
                    ::DiseaseSpecificCallback.diseases_ids_for_key(:investigator_treatment_date_task).include?(disease.id) &&
                    !parent_event.try(:investigator).nil?
                )
              end

              def assign_investigator_treatment_date_task
                self.interested_party.treatments.each do |pt|
                  if pt.treatment_date_changed? || pt.treatment_id_changed?
                    assign_task(I18n.translate('perinatal_hep_b_management.post_serological_investigator_task_name'), pt.treatment_date+1.month, 'hep_b_dose_three') if pt.treatment.try(:treatment_name) == "Hepatitis B Dose 3"
                    assign_task(I18n.translate('perinatal_hep_b_management.post_serological_investigator_task_name'), pt.treatment_date+1.month, 'hep_b_comvax_dose_four') if pt.treatment.try(:treatment_name) == "Hepatitis B - Comvax Dose 4"
                  end
                end
                return true
              end

              def assign_task(task_name, due_date, task_tracking_key)
                task = existing_task_for_event?(task_tracking_key)
                task.nil? ? create_vaccination_task(task_name, due_date, task_tracking_key) : update_vaccination_task(task, due_date)
              end

              def existing_task_for_event?(task_tracking_key)
                Task.find_by_event_id_and_task_tracking_key(self.id, task_tracking_key)
              end

              def create_vaccination_task(name, due_date, task_tracking_key)
                Task.create!(:name => name,
                  :event => self,
                  :user => parent_event.investigator,
                  :due_date => due_date,
                  :category => ::ExternalCode.find_by_code_name_and_the_code('task_category', 'TM'),
                  :status => "pending",
                  :task_tracking_key => task_tracking_key.to_s
                )
              end

              def update_vaccination_task(task, new_due_date)
                task.update_attributes!(:due_date => new_due_date)
              end

              def log_task_assignment_error(exception)
                I18nLogger.error("task_assignment_failed")
                DEFAULT_LOGGER.error(exception.message)
                DEFAULT_LOGGER.error(exception.backtrace)
                self.errors.add_to_base(I18n.t('task_assignment_failed'))
                return false
              end

              base.alias_method_chain :before_save, :p_hep_b_before_save
            end
          end

        end
      end
    end
  end
end
