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
class DiseasesOrganism < ActiveRecord::Base
  belongs_to :disease
  belongs_to :organism

  validates_uniqueness_of :organism_id, :scope => :disease_id

  class << self

    def load_from_yaml(str_yaml)
      assoc = YAML.load str_yaml
      assoc.each do |key, value|
        logger.info "Processing #{key}"
        next if key == 'Unclassified'
        value[:organisms].each do |organism_attr|
          organism = Organism.find(:first, :conditions => ['lower(organism_name) = ?', organism_attr[:organism_name].downcase]) || Organism.create(organism_attr)
          value[:diseases].each do |disease_attr|
            disease = Disease.find_by_disease_name(disease_attr[:disease_name])
            logger.debug " #{disease_attr.inspect}"
            organism.diseases << disease unless organism.diseases.include?(disease)
          end
          organism.save!
        end if value[:organisms]
      end
    end

  end
end
