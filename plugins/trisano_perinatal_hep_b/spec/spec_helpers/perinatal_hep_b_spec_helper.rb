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

module PerinatalHepBSpecHelper

  def p_hep_b_path
    File.join(RAILS_ROOT, 'vendor', 'trisano', 'trisano_perinatal_hep_b')
  end

  def add_expected_delivery_facility_to_event(event, facility_name)
    facility_place_entity = create_delivery_facility!(:expected_delivery, facility_name)
    expected_delivery_facility = Factory.create(:expected_delivery_facility,
      :place_entity => facility_place_entity
    )
    event.expected_delivery_facility = expected_delivery_facility
    event.save!
    expected_delivery_facility
  end

  def add_actual_delivery_facility_to_event(event, facility_name, actual_delivery_facilities_participations_attributes={})
    facility_place_entity = create_delivery_facility!(:actual_delivery, facility_name)
    actual_delivery_facilities_participation = Factory.create(:actual_delivery_facilities_participation, actual_delivery_facilities_participations_attributes)
    actual_delivery_facility = Factory.create(:actual_delivery_facility,
      :place_entity => facility_place_entity,
      :actual_delivery_facilities_participation => actual_delivery_facilities_participation
    )
    event.actual_delivery_facility = actual_delivery_facility
    event.save!
    actual_delivery_facility
  end

  def add_health_care_provider_to_event(event, person_attributes={}, health_care_providers_participations_attributes={})
    provider_person = Factory.create(:person, person_attributes)
    provider_person_entity = Factory.create(:person_entity, :person => provider_person)
    health_care_provider = Factory.create(:health_care_provider, :person_entity => provider_person_entity)
    event.health_care_provider = health_care_provider
    event.save!
    health_care_provider
  end

  def create_delivery_facility!(type, name)
    create_place_entity!(name, type)
  end

  def given_p_hep_b_core_fields_loaded
    Factory.create(:cmr_section_core_field, :key => 'morbidity_event[pregnancy_status_section]') unless CoreField.find_by_key("morbidity_event[pregnancy_status_section]")
    Factory.create :cmr_section_core_field, :key => 'morbidity_event[health_care_provider][section]' unless CoreField.find_by_key("morbidity_event[health_care_provider][section]")
    Factory.create :cmr_section_core_field, :key => 'morbidity_event[event_auditing_section]' unless CoreField.find_by_key("morbidity_event[event_auditing_section]")
    Factory.create :cmr_section_core_field, :key => 'contact_event[treatments_section]' unless CoreField.find_by_key("contact_event[treatments_section]")
    @core_fields = p_hep_b_core_fields
    CoreField.load!(@core_fields)
  end

  def given_ce_core_fields_to_replace_loaded
    @ce_core_fields = YAML::load_file(File.join(RAILS_ROOT, 'db/defaults/core_fields.yml'))
    @replacement_core_fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../db/defaults/core_field_replacements.yml'))
    @replacement_core_fields_keys = @replacement_core_fields.collect {|cf| cf['key']}
    @ce_core_fields_to_load = []

    @ce_core_fields.each do |core_field|
      if @replacement_core_fields_keys.include?(core_field["key"])
        @ce_core_fields_to_load << core_field
      end
    end

    CoreField.load!(@ce_core_fields_to_load)
  end

  def given_hep_b_codes_loaded
    code_name = CodeName.find_or_initialize_by_code_name(:code_name => 'treatment_type', :external => false)
    code_name.save! if code_name.new_record?
    codes = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/misc/en_codes.yml'))
    Code.load!(codes)
  end

  def given_hep_b_external_codes_loaded
    ExternalCode.load_hep_b_external_codes!
  end

  def given_p_hep_b_treatments_loaded
    given_hep_b_codes_loaded
    treatments = YAML.load_file(File.join(File.dirname(__FILE__), '../../db/defaults/treatments.yml'))
    Treatment.load!(treatments)
  end

  def given_p_hep_b_disease_specific_callbacks_loaded
    DiseaseSpecificCallback.create_perinatal_hep_b_associations
  end

  def p_hep_b_core_fields
    YAML.load_file(File.join(p_hep_b_path, 'db/defaults/core_fields.yml'))
  end

  def given_p_hep_b_csv_fields_loaded
    CsvField.load_csv_fields(p_hep_b_csv_fields)
  end

  def p_hep_b_csv_fields
    YAML::load_file(File.join(File.dirname(__FILE__), '../../config/misc/en_csv_fields.yml'))
  end

end
