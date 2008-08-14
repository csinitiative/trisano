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

require "migration_helpers"
class UpdateCodesForeignKeys < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
      #addresses
      remove_foreign_key(:addresses, :county)
      add_foreign_key(:addresses, :county_id, :external_codes)
      remove_foreign_key(:addresses, :state)
      add_foreign_key(:addresses, :state_id, :external_codes)

      #clinicals
      remove_foreign_key(:clinicals, :lab_yn)
      add_foreign_key(:clinicals, :test_public_health_lab_id, :external_codes)

      #clusters
      remove_foreign_key(:clusters, :cluster_status)
      add_foreign_key(:clusters, :cluster_status_id, :external_codes)

      #disease_events
      remove_foreign_key(:disease_events, :died)
      add_foreign_key(:disease_events, :died_id, :external_codes)
      remove_foreign_key(:disease_events, :hospitalized)
      add_foreign_key(:disease_events, :hospitalized_id, :external_codes)

      #entities_locations
      remove_foreign_key(:entities_locations, :location_type)
      add_foreign_key(:entities_locations, :entity_location_type_id, :external_codes)
      remove_foreign_key(:entities_locations, :primary_yn)
      add_foreign_key(:entities_locations, :primary_yn_id, :external_codes)

      #entity_groups
      remove_foreign_key(:entity_groups, :entitygrouptypecode)
      add_foreign_key(:entity_groups, :entity_group_type_id, :external_codes)

      #events
      remove_foreign_key(:events, :imported_from)
      add_foreign_key(:events, :imported_from_id, :external_codes)
      remove_foreign_key(:events, :event_case_status)
      add_foreign_key(:events, :event_case_status_id, :external_codes)
      remove_foreign_key(:events, :event_status)
      add_foreign_key(:events, :event_status_id, :external_codes)

      #lab_results
      remove_foreign_key(:lab_results, :specimensourceid)
      add_foreign_key(:lab_results, :specimen_source_id, :external_codes)
      remove_foreign_key(:lab_results, :testedatuphlynid)
      add_foreign_key(:lab_results, :tested_at_uphl_yn_id, :external_codes)

      #participations_risk_factors
      remove_foreign_key(:participations_risk_factors, :daycareassoc)
      add_foreign_key(:participations_risk_factors, :day_care_association_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :pregnant)
      add_foreign_key(:participations_risk_factors, :pregnant_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :healthcareworker)
      add_foreign_key(:participations_risk_factors, :healthcare_worker_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :groupliving)
      add_foreign_key(:participations_risk_factors, :group_living_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :foodhandler)
      add_foreign_key(:participations_risk_factors, :food_handler_id, :external_codes)

      #participation_treatments
      remove_foreign_key(:participations_treatments, :treatment_given_yn)
      add_foreign_key(:participations_treatments , :treatment_given_yn_id, :external_codes)

      #people
      remove_foreign_key(:people, :code_birthgender)
      add_foreign_key(:people, :birth_gender_id, :external_codes)
      remove_foreign_key(:people, :ethnicity)
      add_foreign_key(:people, :ethnicity_id, :external_codes)
      remove_foreign_key(:people, :primary_language)
      add_foreign_key(:people, :primary_language_id, :external_codes)
  end

  def self.down
      #addresses
      remove_foreign_key(:addresses, :county_id)
      add_foreign_key(:addresses, :county, :codes)
      remove_foreign_key(:addresses, :state_id)
      add_foreign_key(:addresses, :state, :codes)

      #clinicals
      remove_foreign_key(:clinicals, :test_public_health_lab_id)
      add_foreign_key(:clinicals, :lab_yn, :codes)

      #clusters
      remove_foreign_key(:clusters, :cluster_status_id)
      add_foreign_key(:cluserts, :cluster_status, :external_codes)

      #disease_events
      remove_foreign_key(:disease_events, :died_id)
      add_foreign_key(:disease_events, :died, :codes)
      remove_foreign_key(:disease_events, :hospitalized_id)
      add_foreign_key(:disease_events, :hospitalized_, :codes)

      #entities_locations
      remove_foreign_key(:entities_locations, :entity_location_type_id)
      add_foreign_key(:entities_locations, :location_type, :codes)
      remove_foreign_key(:entities_locations, :primary_yn_id)
      add_foreign_key(:entities_locations, :primary_yn, :codes)

      #entity_groups
      remove_foreign_key(:entity_groups, :entity_group_type_code_id)
      add_foreign_key(:entity_groups, :entitygrouptype, :codes)

      #events
      remove_foreign_key(:events, :imported_from_id)
      add_foreign_key(:events, :imported_from, :codes)
      remove_foreign_key(:events, :event_case_status_id)
      add_foreign_key(:events, :event_case_status, :external_codes)
      remove_foreign_key(:events, :event_status_id)
      add_foreign_key(:events, :event_status, :external_codes)

      #lab_results
      remove_foreign_key(:lab_results, :specimen_source_id)
      add_foreign_key(:lab_results, :specimensourceid, :codes)
      remove_foreign_key(:lab_results, :tested_at_uphl_yn_id)
      add_foreign_key(:lab_results, :testedatuphlynid, :codes)

      #participations_risk_factors
      remove_foreign_key(:participations_risk_factors, :day_care_association_id)
      add_foreign_key(:participations_risk_factors, :daycareassoc, :codes)
      remove_foreign_key(:participations_risk_factors, :pregnant_id)
      add_foreign_key(:participations_risk_factors, :pregnant, :codes)
      remove_foreign_key(:participations_risk_factors, :healthcare_worker_id)
      add_foreign_key(:participations_risk_factors, :healthcareworker, :codes)
      remove_foreign_key(:participations_risk_factors, :group_living_id)
      add_foreign_key(:participations_risk_factors, :groupliving, :codes)
      remove_foreign_key(:participations_risk_factors, :food_handler_id)
      add_foreign_key(:participations_risk_factors, :foodhandler, :codes)

      #participation_treatments
      remove_foreign_key(:participation_treatments, :treatment_given_yn_id)
      add_foreign_key(:participation_treatments , :treatment_given_yn, :codes)

      #people
      remove_foreign_key(:people, :birth_gender_id)
      add_foreign_key(:people, :code_birthgender, :codes)
      remove_foreign_key(:people, :ethnicity_id)
      add_foreign_key(:people, :ethnicity, :codes)
      remove_foreign_key(:people, :primary_language_id)
      add_foreign_key(:people, :primary_language, :codes)
  end
end
