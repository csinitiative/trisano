class Utilities
  def self.model_empty?(model)
    model.nil? or model.attributes.all? {|k, v| v.blank?}
  end
end
