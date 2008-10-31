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

class Disease < ActiveRecord::Base
  validates_presence_of :disease_name

  has_and_belongs_to_many :external_codes

  class << self

    def find_active(*args)
      with_scope(:find => {:conditions => ['active = ?', true]}) do
        find(*args)
      end
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

  def case_status_where_clause
    codes = external_codes.collect(&:id)
    "(disease_id='#{self.id}' AND udoh_case_status_id IN (#{codes.join(',')}))" unless codes.empty?

  end

  def invalid_case_status_where_clause
    codes = external_codes.collect(&:id)
    "(disease_id='#{self.id}' AND udoh_case_status_id NOT IN (#{codes.join(',')}))" unless codes.empty?
  end

  # this is a hack until I can set up a proper polymorphic has_many :through
  def cdc_code
    #cdc_disease_column = ExportColumn.cdc_disease_id
    export_conversion_value = ExportConversionValue.find(:first, 
                                :conditions => ['export_column_id=? and value_from=?', 
                                                9, self.disease_name])
    export_conversion_value.nil? ? nil : export_conversion_value.value_to
  end

end
