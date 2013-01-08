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

class DiseaseSpecificCallback < ActiveRecord::Base

  belongs_to :disease
  validates_presence_of :callback_key, :disease_id
  
  class << self
    def diseases_ids_for_key(callback_key)
      DiseaseSpecificCallback.find_all_by_callback_key(callback_key.to_s).collect {|dsc| dsc.disease_id}
    end

    def callbacks(disease)
      return [] if disease.nil?
      DiseaseSpecificCallback.all(:conditions => { :disease_id => disease }).map(&:callback_key)
    end
  
    def create_associations(callbacks)
      reset_column_information
      transaction do
        callbacks.each do |callback|
          disease = Disease.find_by_disease_name(callback["disease_name"])
          raise "Disease not found by name #{callback["disease_name"]}" if disease.nil?
          dsc = DiseaseSpecificCallback.find_or_initialize_by_disease_id_and_callback_key(disease.id, callback["callback_key"])
          dsc.save! if dsc.new_record?
        end
      end
    end
  end
end
