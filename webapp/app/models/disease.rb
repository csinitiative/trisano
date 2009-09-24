# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

  validates_presence_of :disease_name

  has_and_belongs_to_many :external_codes
  has_and_belongs_to_many :export_columns
  has_and_belongs_to_many :avr_groups

  has_many :diseases_loinc_codes, :dependent => :destroy
  has_many :loinc_codes, :through => :diseases_loinc_codes

  has_many :common_test_types, :finder_sql => %q{
    SELECT common_test_types.* FROM common_test_types
      JOIN loinc_codes ON common_test_types.id = loinc_codes.common_test_type_id
      JOIN diseases_loinc_codes ON loinc_codes.id = diseases_loinc_codes.loinc_code_id
    WHERE diseases_loinc_codes.disease_id = #{id}
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
      "(#{diseases.join(' OR ')})" unless diseases.compact!.empty?
    end

    def with_no_export_status
      ids = ActiveRecord::Base.connection.select_all('select distinct disease_id from diseases_external_codes')
      find(:all, :conditions => ['id not in (?)', ids.collect{|id| id['disease_id']}])
    end

    def with_invalid_case_status_clause
      diseases = collect_diseases(&:invalid_case_status_where_clause)
      "(#{diseases.join(' OR ')})" unless diseases.compact!.empty?
    end

  end

  def live_forms(event_type = "MorbidityEvent")
    Form.find(:all,
      :joins => "INNER JOIN diseases_forms df ON df.form_id = id",
      :conditions => ["df.disease_id = ? AND status = 'Live' AND event_type = ?",  self.id, event_type.underscore]
    )
  end

  def case_status_where_clause
    codes = external_codes.collect(&:id)
    # Why can't I use sanitize_sql_for_conditions here?  Should be safe though since id field.
    "(disease_id=#{self.id.untaint} AND state_case_status_id IN (#{codes.collect{ |id| id.untaint }.join(',')}))" unless codes.empty?
  end

  def invalid_case_status_where_clause
    codes = external_codes.collect(&:id)
    # Why can't I use sanitize_sql_for_conditions here?  Should be safe though since id field.
    "(disease_id='#{self.id.untaint}' AND state_case_status_id NOT IN (#{codes.collect{ |id| id.untaint }.join(',')}))" unless codes.empty?
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

end
