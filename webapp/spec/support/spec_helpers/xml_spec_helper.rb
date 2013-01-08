# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
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
