class ExtendedFormBuilder < ActionView::Helpers::FormBuilder

  def dropdown_code_field(attribute, code_name, *args)
    self.collection_select(attribute, codes(code_name), :id, :code_description, *args)
  end

  def multi_select_code_field(attribute, code_name, options, html_options)
    html_options[:multiple] = true
    self.collection_select(attribute, codes(code_name), :id, :code_description, options, html_options)
  end

  def codes(code_name)
    @codes ||= Code.find(:all, :order => 'sort_order')
    @codes.select {|code| code.code_name == code_name}
  end
end
