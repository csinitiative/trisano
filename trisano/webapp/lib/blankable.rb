module Blankable
  def values_blank?
    blankable_values.inject(true) do |result, value|
      result && if value.respond_to?(:values_blank?)
        value.values_blank?
      elsif value.respond_to?(:blank?)
        value.blank?
      elsif value.respond_to?(:empty?)
        value.empty?
      else
        value.nil?
      end
    end
  end
end

class Hash
  include Blankable
  def blankable_values
    values
  end
end

class Array
  include Blankable
  def blankable_values
    self
  end
end
