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

class Organism < ActiveRecord::Base
  default_scope :order => 'organism_name'

  before_validation :strip_organism_name

  validates_presence_of   :organism_name
  validates_uniqueness_of :organism_name, :case_sensitive => false
  validates_length_of     :organism_name, :maximum => 255, :allow_blank => true

  has_many :loinc_codes

  has_many :diseases_organisms, :dependent => :destroy
  has_many :diseases, :through => :diseases_organisms

  named_scope :all_by_name, lambda { |name|
    { :conditions => ['lower(organism_name) = ?', name.downcase] }
  }

  private

  def strip_organism_name
    self.organism_name.strip! if attribute_present? :organism_name
  end

end
