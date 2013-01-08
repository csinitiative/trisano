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

module Trisano::NestedAttributesHelper
  def place_blank?(attrs)
    unnest_from_entity(attrs) do |attrs|
      nested_attributes_blank? attrs["place_attributes"]
    end
  end
  
  def canonical_address_blank?(attrs)
    unnest_from_entity(attrs) do |attrs|
      nested_attributes_blank? attrs["canonical_address_attributes"]
    end
  end

  def place_and_canonical_address_blank?(attrs)
    place_blank?(attrs) && canonical_address_blank?(attrs)
  end

  def attrs_present?(attrs)
    attrs.any? { |k, v| v.present? }
  end

  def key_value_present?(params, key)
    attrs = params.clone
    key_value = attrs.delete key
    key_value.to_s.present?
  end

  def nested_attributes_blank?(params)
    return true if params.nil?

    attrs = params.clone.delete_if { |k,v| k=="position" }
    new_repeater_checkboxes = attrs.delete "new_repeater_checkboxes"
    new_repeater_radio_buttons = attrs.delete  "new_repeater_radio_buttons"

    # for investigator form sections, we want to also ignore section_element_id
    new_repeater_answers = attrs.delete "new_repeater_answers"
    attrs.delete("section_element_id") if new_repeater_answers.present?
  
    return false if attrs_present?(attrs)
    
    new_repeater_checkboxes.each do |question_id, attrs|
      return false if key_value_present?(attrs, "check_box_answer")
    end if new_repeater_checkboxes 

    new_repeater_radio_buttons.each do |question_id, attrs|
      return false if key_value_present?(attrs, "radio_button_answer")
    end if new_repeater_radio_buttons 

    new_repeater_answers.each do |attrs|
      return false if attrs["text_answer"].present?
    end if new_repeater_answers 

    return true
  end

  def unnest_from_entity(attrs)
    if attrs.has_key?("place_entity_attributes")
      yield attrs["place_entity_attributes"]
    elsif attrs.has_key?("person_entity_attributes")
      yield attrs["person_entity_attributes"]
    else
      yield attrs
    end
  end
end
