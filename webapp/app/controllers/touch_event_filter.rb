class TouchEventFilter
  def self.filter(controller)
    touch controller.instance_variable_get("@event") unless controller.request.xhr?
  end

  def self.touch(object, attribute = nil)
    current_time = Time.current

    if attribute
      object.write_attribute(attribute, current_time)
    else
      object.write_attribute('updated_at', current_time) if object.respond_to?(:updated_at)
      object.write_attribute('updated_on', current_time) if object.respond_to?(:updated_on)
    end
  
    object.save!
  end
end
