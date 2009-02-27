class Utilities
  class << self
    def model_empty?(model)
      model.nil? or model.attributes.all? {|k, v| v.blank?}
    end

    def underscore(string)
      string.strip.gsub(/\s+/, "_")
    end

    def make_queue_name(string)
      string.strip.downcase.gsub(/\s+/, "_").camelize
    end
  end
end

module CallChainable

  def safe_call_chain(*messages)
    receiver = self
    messages.each do |msg|
      return nil if receiver.nil?
      receiver = receiver.send(msg)
    end
    receiver
  end

end

ActiveRecord::Base.send(:include, CallChainable)
