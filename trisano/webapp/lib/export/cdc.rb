# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

module Export
  module Cdc
    module Event
      
      def check_cdc_updates        
        self.cdc_update = cdc_attributes_changed?(old_attributes)
      end
      
      private
      
      def cdc_attributes_changed?(old_attributes)
        return true if new_record?
        return false unless old_attributes                
        return true unless nested_attributes['disease_id'] == safe_call_chain(:disease, :disease_id)

        cdc_fields = %w(first_reported_PH_date udoh_case_status_id imported_from_id event_onset_date)
        old_attributes.select {|k, v| cdc_fields.include?(k)}.reject do |field, value|
          self.attributes[field] == value
        end.size > 0
      end
      
    end

    module Record

      def to_cdc
        %w(exp_rectype
           exp_update
           exp_state
           exp_year
           exp_caseid
           exp_site
           exp_week
           exp_event
           exp_count
           exp_county
           exp_birthdate
           age_at_onset
           exp_agetype
           exp_sex exp_race
           exp_ethnicity
           exp_eventdate
           exp_datetype
           udoh_case_status_id
           exp_imported
           exp_outbreak
          ).map { |field| send field }.join
      end

      def age_at_onset
        self['age_at_onset'].to_s.rjust(3, '0')
      end
      
      # This is a cheat. Sometime we should go back and fix the view.
      def udoh_case_status_id
        return '9' unless status_code = self['udoh_case_status_id']
        external_code = ExternalCode.find(status_code)
        cdc_code = ExportConversionValue.find(:first, :conditions => 
                     ["export_column_id=? and value_from=?", 
                      20, external_code.the_code])
        cdc_code.value_to
      end
           

      def method_missing(method, *args)
        if self.has_key? method.to_s
          self.class.send(:define_method, method, lambda {self[method.to_s]})
          send(method, args)
        else
          super
        end
      end

    end
  end
end


