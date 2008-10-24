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
       
    def check_cdc_updates      
      self.cdc_update = cdc_attributes_changed?(old_attributes)
    end

    def cdc_mmwr_year
      Date.new(self.MMWR_year).strftime('%y')
    end

    def cdc_record_number
      record_number[-6,6]
    end

    def cdc_disease_code
      safe_call_chain(:disease_event, :disease, :cdc_code)
    end

    def cdc_county_code
      safe_call_chain(:active_patient, :primary_entity, :address, :county, :the_code) || "999"
    end

    def cdc_birth_date
      date = safe_call_chain(:active_patient, :primary_entity, :person, :birth_date)
      date ? date.strftime("%Y%d%m") : '99999999'
    end

    def cdc_age_at_onset
      self.age_at_onset.to_s.rjust(3, '0')
    end

    def cdc_age_type
      self.age_info.age_type.the_code
    end

    def cdc_lab_date      
      result_dates = []
      self.labs.each do |lab|
        lab.lab_results.each do |result|
          result_dates << result.lab_test_date
        end
      end
      result_dates.sort.first
    end

    def cdc_case_status
    end

    def to_cdc 
      ['M', ' ', '49', cdc_mmwr_year, cdc_record_number,
       'S01', self.MMWR_week, cdc_disease_code, '00001',
       cdc_county_code, cdc_birth_date, cdc_age_at_onset,
       cdc_age_type, ' ', ' ', ' ', cdc_event_date[0].strftime("%y%m%d"), 
       cdc_event_date[1], cdc_case_status, ' ', ' '].join 
    end

    private

    def cdc_event_date
      [[self.event_onset_date, 1],
       [self.safe_call_chain(:disease, :disease_onset_date), 2],
       [cdc_lab_date, 3],
       [self.first_reported_PH_date, 4],
       [self.created_at, 5]].reject do |a|
        a[0].nil?
      end.sort{|a1, a2| a1[0].to_date <=> a2[0].to_date}.first
    end


    def cdc_attributes_changed?(old_attributes)
      return false unless old_attributes
      
      cdc_fields = %w(first_reported_PH_date udoh_case_status_id)
      old_attributes.select {|k, v| cdc_fields.include?(k)}.reject do |field, value|
        self.attributes[field] == value
      end.size > 0
    end

  end
end
