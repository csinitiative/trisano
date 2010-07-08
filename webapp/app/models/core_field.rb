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

class CoreField < ActiveRecord::Base
  include I18nCoreField

  belongs_to :code_name
  has_many :core_fields_diseases, :dependent => :destroy
  has_many :diseases, :through => :core_fields_diseases

  before_validation :normalize_attributes

  class << self

    def find_event_fields_for(event_type, *args)
      return [] if event_type.blank?
      with_scope(:find => {
                   :conditions => ["event_type=?", event_type],
                   :include => :core_fields_diseases
                 }) do
        find(*args)
      end
    end

    # uses the memoization cache
    def event_fields(event_or_type)
      event_type = (event_or_type.is_a?(Event) ? event_or_type.type : event_or_type.to_s).underscore
      event_fields_hash[event_type] ||= find_event_fields_for(event_type, :all).inject({}) do |hash, field|
        hash[field.key] = field
        hash
      end
    end

    def flush_memoization_cache
      @event_fields_hash = nil
    end

    def load!(hashes)
      transaction do
        hashes.each do |attrs|
          unless self.find_by_key(attrs['key'])
            if (code_name = attrs.delete('code_name'))
              attrs['code_name'] = CodeName.find_by_code_name(code_name)
            end
            CoreField.create!(attrs)
          end
        end
      end
    end

    private

    def event_fields_hash
      @event_fields_hash ||= {}
    end
  end

  def core_path
    self.key
  end

  def rendered?(event)
    disease = event.try(:disease_event).try(:disease)

    if assoc = disease_association(disease)
      assoc.rendered
    else
      if disease_specific
        return false
      else
        return true
      end
    end
  end

  private

  def normalize_attributes
    self.event_type = self.event_type.to_s if self.event_type
  end

  # do this instead of going to the db
  def disease_association(disease)
    core_fields_diseases.select do |cfd|
      cfd.disease_id == disease.try(:id)
    end.first
  end

end
