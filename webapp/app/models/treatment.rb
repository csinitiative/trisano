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

class Treatment < ActiveRecord::Base
  belongs_to :treatment_type, :class_name => 'Code', :foreign_key => 'treatment_type_id'
  has_many :disease_specific_treatments, :dependent => :destroy
  has_many :diseases, :through => :disease_specific_treatments

  validates_presence_of :treatment_name
  validates_uniqueness_of :treatment_name

  named_scope :active,
    :conditions => ["active = ?", true],
    :order => "treatment_name ASC"

  named_scope :default, {
    :conditions => { :default => true }
  }

  class << self

    def all_by_type(type_code)
      raise ArgumentError unless type_code.is_a?(Code)
      self.find(:all, :conditions => ["treatment_type_id = ?", type_code.id], :include => :treatment_type)
    end

    def load!(hashes)
      reset_column_information
      transaction do
        attributes = Treatment.new.attribute_names
        hashes.each do |attrs|
          treatment_type_code = attrs.fetch('treatment_type_code')
          code = Code.find_by_code_name_and_the_code('treatment_type', treatment_type_code)
          raise "Could not find treatment_type code for #{treatment_type_code}" if code.nil?
          unless treatment = self.find_by_treatment_type_id_and_treatment_name(code.id, attrs["treatment_name"])
            load_attrs = attrs.reject { |key, value| !attributes.include?(key) }
            load_attrs.merge!(:treatment_type_id => code.id)
            treatment = Treatment.create!(load_attrs)
          end
          if attrs['associated_diseases'] and not attrs['associated_diseases'].empty?
            diseases = Disease.all(:conditions => ['disease_name IN (?)', attrs['associated_diseases']])
            diseases.each do |disease|
              unless disease.treatments.include?(treatment)
                disease.treatments <<  treatment
              end
            end
          end
        end
      end
    end
  end

  def merge(treatment_ids)
    treatment_ids = [treatment_ids].flatten.compact.uniq.collect { |id| id.to_i }

    if treatment_ids.empty?
      errors.add(:base, :no_treatments_for_merging)
      return nil
    end

    if treatment_ids.include?(self.id)
      errors.add(:base, :cannot_merge_treatment_into_itself)
      return nil
    end

    begin
      Treatment.transaction do
        treatment_ids.each do |treatment_id|
          ParticipationsTreatment.find_all_by_treatment_id(treatment_id).each do |pt|
            pt.update_attribute(:treatment_id, self.id)
          end

          Treatment.destroy(treatment_id)
        end
      end

      return true
    rescue Exception => ex
      logger.error ex
      errors.add(:base, :failed_treatment_merge, :msg => ex.message)
      return nil
    end
  end

end
