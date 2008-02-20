require 'chronic'

class Place < ActiveRecord::Base
  belongs_to :place_type, :class_name => 'Code'
  belongs_to :entity 

  # TODO:  Does not yet take into account multiple edits of a single hospital.  Can probably be optimized.
  def self.hospitals
    find_all_by_place_type_id(Code.find_by_code_name_and_code_description('placetype', 'Hospital').id)
  end

  def is_hospital?
    place_type_id == Code.find_by_code_name_and_code_description('placetype', 'Hospital').id
  end
end
