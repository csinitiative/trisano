# Custom XmlMini implementation for the TriSano XML api
module ActiveSupport
  module XmlMini_NamespaceFilter
    extend XmlMini_REXML
    extend self

    private

    def merge_element!(hash, element)
      return unless element.namespace.blank?
      super
    end

    def get_attributes(element)
      attributes = super
      remove_namespace_attributes(attributes)
    end

    def remove_namespace_attributes(attributes)
      attributes = attributes.stringify_keys
      attributes.keys.each do |k|
        attributes.delete(k) if k.starts_with? 'xmlns'
      end
      attributes
    end
  end
end
