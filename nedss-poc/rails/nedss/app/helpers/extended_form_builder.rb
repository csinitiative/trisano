class ExtendedFormBuilder < ActionView::Helpers::FormBuilder

  def dropdown_code_field(attribute, code_name, *args)
    codes = Code.find_all_by_code_name(code_name, :order => 'code_description')
    self.collection_select(attribute, codes, :id, :code_description, *args)
  end

  def multi_select_code_field(attribute, code_name, options, html_options)
    codes = Code.find_all_by_code_name(code_name, :order => 'code_description')
    html_options[:multiple] = true
    self.collection_select(attribute, codes, :id, :code_description, options, html_options)
  end
end
