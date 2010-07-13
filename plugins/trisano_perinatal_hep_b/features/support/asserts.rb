
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

  def assert_printed_field(section, content)
    assert_tag 'span', {
      :attributes => { :class => 'horiz' },
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

end
