# Custom XmlMini implementation for the TriSano XML api
module ActiveSupport
  module XmlMini_NamespaceFilter
    extend XmlMini_REXML
    extend self

    private

    def merge_element!(hash, element)
      return unless element.namespace.blank?
      result = super
      result = result.each {|k, v| result.delete(k) if v.blank? }
      result
    end

    def get_attributes(element)
      attributes = super
      remove_attributes_if(attributes) do |k, v|
        k.starts_with("xmlns") or k == 'rel'
      end
    end

    def remove_attributes_if(attributes)
      attributes = attributes.stringify_keys
      attributes.each do |k, v|
        attributes.delete(k) if yield(k, v)
      end
      attributes
    end
  end
end
