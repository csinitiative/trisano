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

class CsvExportRefactorSupport < ActiveRecord::Migration
  def self.up
    if ENV['UPGRADE']
      ActiveRecord::Base.transaction do
        puts "Updating CSV export configuration"

        puts "Updating lab export configuration"
        lab_organism = CsvField.find_by_long_name("lab_organism")
        lab_organism.update_attributes!(
          :use_description => "try(:organism).try(:organism_name)",
          :collection => "lab_results"
        )

        lab_test_result = CsvField.find_by_long_name("lab_test_result")
        lab_test_result.update_attributes!(
          :use_description => "try(:test_result).try(:code_description)",
          :use_code => "try(:test_result).try(:the_code)",
          :collection => "lab_results"
        )

        lab_test_status = CsvField.find_by_long_name("lab_test_status")
        lab_test_status.update_attributes!(
          :use_description => "try(:test_status).try(:code_description)",
          :use_code => "try(:test_status).try(:the_code)",
          :collection => "lab_results"
        )

        lab_result_value = CsvField.find_by_long_name("lab_result_value")
        lab_result_value.update_attributes!(
          :use_description => "try(:result_value)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_units = CsvField.find_by_long_name("lab_units")
        lab_units.update_attributes!(
          :use_description => "try(:units)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_reference_range = CsvField.find_by_long_name("lab_reference_range")
        lab_reference_range.update_attributes!(
          :use_description => "try(:reference_range)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_test_date = CsvField.find_by_long_name("lab_test_date")
        lab_test_date.update_attributes!(
          :use_description => "try(:lab_test_date)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_name = CsvField.find_by_long_name("lab_name")
        lab_name.update_attributes!(
          :use_description => "try(:lab_name)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_specimen_source = CsvField.find_by_long_name("lab_specimen_source")
        lab_specimen_source.update_attributes!(
          :use_description => "try(:specimen_source).try(:code_description)",
          :use_code => "try(:specimen_source).try(:the_code)",
          :collection => "lab_results"
        )

        lab_collection_date = CsvField.find_by_long_name("lab_collection_date")
        lab_collection_date.update_attributes!(
          :use_description => "try(:collection_date)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_test_type = CsvField.find_by_long_name("lab_test_type")
        lab_test_type.update_attributes!(
          :use_description => "try(:test_type).try(:common_name)",
          :use_code => "",
          :collection => "lab_results"
        )

        lab_specimen_sent_to_state = CsvField.find_by_long_name("lab_specimen_sent_to_state")
        lab_specimen_sent_to_state.update_attributes!(
          :use_description => "try(:specimen_sent_to_state).try(:code_description)",
          :use_code => "try(:specimen_sent_to_state).try(:the_code)",
          :collection => "lab_results"
        )

        lab_record_id = CsvField.find_by_long_name("lab_record_id")
        lab_record_id.update_attributes!(
          :use_description => "try(:id)",
          :use_code => "",
          :collection => "lab_results"
        )

        puts "Updating treatment configuration"

        treatment_date = CsvField.find_by_long_name("treatment_date")
        treatment_date.update_attributes!(
          :use_description => "try(:treatment_date)",
          :use_code => "",
          :collection => "interested_party.try(:treatments)"
        )

        stop_treatment_date = CsvField.find_by_long_name("stop_treatment_date")
        stop_treatment_date.update_attributes!(
          :use_description => "try(:stop_treatment_date)",
          :use_code => "",
          :collection => "interested_party.try(:treatments)"
        )

        treatment_name = CsvField.find_by_long_name("treatment_name")
        treatment_name = CsvField.find_by_long_name("treatment") unless treatment_name
        treatment_name.update_attributes!(
          :use_description => "try(:treatment_name)",
          :use_code => "",
          :collection => "interested_party.try(:treatments)"
        )

        treatment_given = CsvField.find_by_long_name("treatment_given")
        treatment_given.update_attributes!(
          :use_description => "try(:treatment_given_yn).try(:code_description)",
          :use_code => "try(:treatment_given_yn).try(:the_code)",
          :collection => "interested_party.try(:treatments)"
        )

        treatment_record_id = CsvField.find_by_long_name("treatment_record_id")
        treatment_record_id.update_attributes!(
          :use_description => "try(:id)",
          :use_code => "",
          :collection => "interested_party.try(:treatments)"
        )

        puts "Remove duplicate treatment field"
        treatment = CsvField.find_by_long_name("treatment")
        treatment.destroy if treatment
      end
    end

  end

  def self.down
  end
end
