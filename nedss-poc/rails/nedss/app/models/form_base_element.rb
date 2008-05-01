class FormBaseElement < FormElement
  belongs_to :form

  def pre_order_walk(&block)
    return if (ret = yield(self)).is_a?(Symbol) && ret == :stop
    children.each { |e| e.pre_order_walk(&block) }
  end 
end
