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

class Disease < ActiveRecord::Base
  include Export::Cdc::DiseaseRules

  before_save :update_cdc_code
  before_validation :strip_disease_name

  validates_presence_of :disease_name

  has_and_belongs_to_many(:cdc_disease_export_statuses,
    :join_table => 'cdc_disease_export_statuses',
    :class_name => 'ExternalCode')
  has_and_belongs_to_many :export_columns
  has_and_belongs_to_many :avr_groups

  has_many :diseases_loinc_codes, :dependent => :destroy
  has_many :loinc_codes, :through => :diseases_loinc_codes

  has_many :core_fields_diseases, :dependent => :destroy
  has_many :core_fields, :through => :core_fields_diseases

  has_many :disease_specific_selections, :dependent => :destroy

  has_many :organisms, :finder_sql => %q{
    SELECT DISTINCT ON (organisms.id) organisms.* FROM organisms
      LEFT JOIN loinc_codes ON organisms.id = loinc_codes.organism_id
      LEFT JOIN diseases_loinc_codes ON loinc_codes.id = diseases_loinc_codes.loinc_code_id
      LEFT JOIN diseases_organisms ON organisms.id = diseases_organisms.organism_id
    WHERE diseases_loinc_codes.disease_id = #{id} OR diseases_organisms.disease_id = #{id}
  }

  has_many :common_test_types, :finder_sql => %q{
    SELECT DISTINCT common_test_types.* FROM common_test_types
      LEFT JOIN loinc_codes ON common_test_types.id = loinc_codes.common_test_type_id
      LEFT JOIN diseases_loinc_codes ON loinc_codes.id = diseases_loinc_codes.loinc_code_id
      LEFT JOIN common_test_types_diseases ON common_test_types.id = common_test_types_diseases.common_test_type_id
    WHERE diseases_loinc_codes.disease_id = #{id} OR common_test_types_diseases.disease_id = #{id}
  }

  class << self

    def find_active(*args)
      with_scope(:find => {:conditions => ['active = ?', true]}) do
        find(*args)
      end
    end

    def find_all_excluding(ids, options = {:order => 'disease_name ASC'})
      unless ids.empty?
        options.merge!(:conditions => ['id NOT IN (?)', ids])
      end
      find_active(:all, options)
    end

    def collect_diseases
      diseases = []
      find(:all).each do |disease|
        diseases << yield(disease) if block_given?
      end
      diseases
    end

    def disease_status_where_clause
      diseases = collect_diseases(&:case_status_where_clause)
      "(#{diseases.join(' OR ')})" unless diseases.compact!.try :empty?
    end

    def with_no_export_status
      ids = ActiveRecord::Base.connection.select_all('select distinct disease_id from cdc_disease_export_statuses')
      find(:all, :conditions => ['id not in (?)', ids.collect{|id| id['disease_id']}])
    end

    def with_invalid_case_status_clause
      diseases = collect_diseases(&:invalid_case_status_where_clause)
      "(#{diseases.join(' OR ')})" unless diseases.compact!.empty?
    end

    def diseases_for_event(event)
      diseases = find_active(:all, :order => 'disease_name ASC')

      if (event.disease_event.try(:disease).try(:active) == false)
        diseases << event.disease_event.disease
        diseases = diseases.sort_by {|disease| disease.disease_name }
      end
      diseases
    end

    def load_from_yaml(str_or_readable)
      transaction do
        YAML.load(str_or_readable).each do |disease_group, data|
          I18nLogger.info("loading_disease_group", :disease_group => disease_group)
          data[:diseases].each do |disease_attr|
            disease = find_or_create_by_disease_name({:active => true}.merge(disease_attr))

            data[:organisms].each do |organism_attr|
              organism = Organism.all_by_name(organism_attr[:organism_name]).first || Organism.create!(organism_attr)
              organism.diseases << disease unless organism.diseases.include?(disease)
            end if data[:organisms]

            data[:loinc_codes].each do |loinc_attr|
              loinc = LoincCode.first(:conditions => loinc_attr)
              loinc.diseases << disease unless loinc.diseases.include?(disease)
            end if data[:loinc_codes]

            data[:common_tests].each do |ctt_attr|
              ctt = CommonTestType.first(:conditions => ['lower(common_name) = ?', ctt_attr[:common_name].downcase]) || CommonTestType.create!(ctt_attr)
              ctt.diseases << disease unless ctt.diseases.include?(disease)
            end if data[:common_tests]
          end
        end
      end
    end
  end

  def live_forms(event_type = "MorbidityEvent")
    Form.find(:all,
      :joins => "INNER JOIN diseases_forms df ON df.form_id = id",
      :conditions => ["df.disease_id = ? AND status = ? AND event_type = ?",  self.id, 'Live', event_type.underscore]
    )
  end

  def case_status_where_clause
    unless self.cdc_disease_export_status_ids.empty?
      self.class.send(:sanitize_sql, ["(disease_id=? AND state_case_status_id IN (?))",
          self.id,
          self.cdc_disease_export_status_ids])
    end
  end

  def invalid_case_status_where_clause
    unless self.cdc_disease_export_status_ids.empty?
      self.class.send(:sanitize_sql, ["(disease_id = ? and state_case_status_id NOT IN (?))",
          self.id,
          self.cdc_disease_export_status_ids])
    end
  end

  def copy_core_fields_from(another_disease)
    transaction do
      CoreFieldsDisease.delete_all(['disease_id = ?', self.id])
      connection.execute(<<-SQL)
        INSERT INTO core_fields_diseases
          SELECT nextval('core_fields_diseases_id_seq'),
                 core_field_id,
                 #{self.id} as disease_id,
                 rendered,
                 NOW() as created_at,
                 NOW() as updated_at,
                 replaced
            FROM core_fields_diseases
           WHERE disease_id = #{another_disease.id}
       SQL
    end
    true
  rescue
    logger.error($!)
    false
  end

  private

  # Debt: The CDC code lives in two places right now: On disease, and as a conversion value. This
  # hook updates the conversion value.
  def update_cdc_code
    unless cdc_code.blank?
      export_column = ExportColumn.find_by_export_column_name("EVENT")
      unless export_column.nil?
        export_value = ExportConversionValue.find_or_initialize_by_export_column_id_and_value_from(export_column.id, disease_name)
        export_value.update_attributes(:value_from => disease_name, :value_to => cdc_code)
      end
    end
  end

  def strip_disease_name
    self.disease_name.strip! if attribute_present? :disease_name
  end

end
