class TouchEventFilter
  def self.filter(controller)
    controller.instance_variable_get("@event").save
  end
end
