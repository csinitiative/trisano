
Cucumber::Rails::World.class_eval do
  def assert_no_delivery_fields(type)
    ancestor_hash = delivery_field_ancestor_hash(type)
    assert_no_tag 'label', :content => "#{type.capitalize} delivery facility"
    assert_no_tag 'label', ancestor_hash.merge(:content => 'Place type')
    assert_no_tag 'label', ancestor_hash.merge(:content => 'Area code')
    assert_no_tag 'label', ancestor_hash.merge(:content => 'Phone number')
    assert_no_tag 'label', ancestor_hash.merge(:content => 'Extension')
  end

  def assert_delivery_fields(type)
    ancestor_hash = delivery_field_ancestor_hash(type)
    assert_tag 'label', :content => "#{type.capitalize} delivery facility"
    assert_tag 'label', ancestor_hash.merge(:content => 'Place type')
    assert_tag 'label', ancestor_hash.merge(:content => 'Area code')
    assert_tag 'label', ancestor_hash.merge(:content => 'Phone number')
    assert_tag 'label', ancestor_hash.merge(:content => 'Extension')
  end

  def assert_printed_field(section, content, html_class=:horiz)
    assert_tag 'span', {
      :attributes => { :class => html_class.to_s },
      :child => {
        :tag => 'span',
        :attributes => { :class => 'print-label' },
        :content => content
      },
      :after => {
        :tag => 'span',
        :attributes => { :class => 'section-header' }
      },
      :parent => {
        :tag => 'div',
        :attributes => { :id => section.to_s }
      }
    }
  end

  def delivery_field_ancestor_hash(type)
    { :parent => { :tag => 'span', :attributes => { :class => 'horiz' } },
      :ancestor => {
        :tag => 'div',
        :attributes => { :id => "#{type}_delivery_facility" }
      }
    }
  end

  def assert_state_manager_data(manager_name)
    assert_auditing_data(:tag => 'label', :content => 'State manager')
    assert_auditing_data(:tag => 'span', :content => manager_name)
  end

  def assert_auditing_data(tag_hash, class_name=:horiz)
    assert_tag('span', show_auditing_section_hash(class_name).merge(:child => tag_hash))
  end

  def show_auditing_section_hash(class_name=:horiz)
    { :attributes => { :class => class_name.to_s },
      :after => {
        :tag => 'legend',
        :content => 'Auditing / Investigation'
      },
      :ancestor => {
        :tag => 'div',
        :attributes => { :id => 'administrative_tab' }
      }
    }
  end
end
