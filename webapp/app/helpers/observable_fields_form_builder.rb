class ObservableFieldsFormBuilder < ActionView::Helpers::FormBuilder
  def observe(method, options={})
    @template.observe_field field_id(method), options
  end

  def field_id(field)
    ActionView::Helpers::InstanceTag.new(self.object_name, field, self, {}).send :tag_id
  end

  def field_name(field)
    ActionView::Helpers::InstanceTag.new(self.object_name, field, self, {}).send :tag_name
  end
end
