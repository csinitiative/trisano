# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class DiseaseSpecificValidation < ActiveRecord::Base

  belongs_to :disease
  validates_presence_of :validation_key, :disease_id
  
  class << self
    def diseases_ids_for_key(validation_key)
      DiseaseSpecificValidation.find_all_by_validation_key(validation_key.to_s).collect {|dsv| dsv.disease_id}
    end
  
    def create_associations(validations)
      reset_column_information
      transaction do
        validations.each do |validation|
          disease = Disease.find_by_disease_name(validation["disease_name"])
          raise "Disease not found by name #{validation["disease_name"]}" if disease.nil?
          dsv = DiseaseSpecificValidation.find_or_initialize_by_disease_id_and_validation_key(disease.id, validation["validation_key"])
          dsv.save! if dsv.new_record?
        end
      end
    end
  end
end
