module XmlSpecHelper
  def assert_xml_field(css_path, field, rel=nil)
    if rel
     response.body.should have_css("#{css_path} #{field.to_s.dasherize}[rel='#{rel}']")
     response.body.should have_css("#{css_path.split.first} atom|link[rel='#{rel}']")
    else
     response.body.should have_css("#{css_path} #{field.to_s.dasherize}")
    end
  end

  def assert_telephone_xml_at_css(css_path)
    [%w(entity_location_type_id https://wiki.csinitiative.com/display/tri/Relationship+-+TelephoneLocationType),
     :area_code,
     :phone_number,
     :extension
    ].each do |field, rel|
      assert_xml_field(css_path, field, rel)
    end
  end

  def assert_address_xml_at_css(css_path)
    [['state_id',  'https://wiki.csinitiative.com/display/tri/Relationship+-+State'],
     ['county_id', 'https://wiki.csinitiative.com/display/tri/Relationship+-+County'],
     'unit_number',
     'postal_code',
     'street_name',
     'street_number',
     'city'
    ].each do |field, rel|
      assert_xml_field(css_path, field, rel)
   end
  end
end
