# Some common rejection methods for nested attributes
ActiveRecord::Base.class_eval do

  private

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

  def nested_attributes_blank?(attrs)
    attrs.nil? ||
      attrs.all? { |k, v| v.blank? }
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
