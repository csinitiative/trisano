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
