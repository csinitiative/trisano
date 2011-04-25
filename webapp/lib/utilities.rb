class Utilities
  class << self
    def parse_phone(phone_no)
      digits = phone_no.gsub(/\D/, '')
      area_code = number = extension = nil
      case digits.length
      when 7
        number = digits
      when 10
        area_code = digits.slice!(0,3)
        number = digits
      when 11..15
        area_code = digits.slice!(0,3)
        number = digits.slice!(0,7)
        extension = digits
      else
        raise ArgumentError, "Number must contain 7, 10, or 11-15 digits"
      end
      return area_code, number, extension
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
