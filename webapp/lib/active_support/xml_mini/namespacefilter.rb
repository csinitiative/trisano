# Custom XmlMini implementation for the TriSano XML api
module ActiveSupport
  module XmlMini_NamespaceFilter
    extend XmlMini_REXML
    extend self

    private

    def merge_element!(hash, element)
      return unless element.namespace.blank?
      result = super
      remove_empty_nested_attributes(result)
      result
    end

    def get_attributes(element)
      attributes = super
      remove_attributes_if(attributes) do |k, v|
        k.starts_with?("xmlns") or k == 'rel'
      end
    end

    private

    def remove_attributes_if(attributes)
      attributes = attributes.stringify_keys
      attributes.each do |k, v|
        attributes.delete(k) if yield(k, v)
      end
      attributes
    end

    def remove_empty_nested_attributes(result)
      result.each do |k, v|
        result.delete(k) if nested_attribute?(k) && v.values.all? { |v| v.blank? }
      end
    end

    def nested_attribute?(attribute)
      attribute.to_s.ends_with?('-attributes') ||
        attribute.to_s.ends_with?('_attributes') ||
        attribute.to_s =~ /^i\d+$/i
    end
  end
end
