
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
    new_repeater_answers = attrs.delete "new_repeater_answers"
  
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
