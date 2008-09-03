class Utilities
  class << self
    def model_empty?(model)
      model.nil? or model.attributes.all? {|k, v| v.blank?}
    end

    def underscore(string)
      string.strip.gsub(/\s+/, "_")
    end
  end
end
