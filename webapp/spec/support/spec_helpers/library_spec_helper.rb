module LibrarySpecHelper

  def library_group(options = {}, &block)
    options.symbolize_keys!
    options[:is_template] ||= true
    group_element = Factory.build(:group_element, options)
    group_element.save_and_add_to_form
    block[group_element] if block_given?
    group_element
  end

end
