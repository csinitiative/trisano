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
module CommonTestTypesHelper

  def common_test_type_tools(common_test_type)
    haml_tag :div, :class => 'tools' do
      haml_concat link_to_unless_current(t('show'), common_test_type)
      haml_concat "|"
      haml_concat link_to_unless_current(t('edit'), edit_common_test_type_path(common_test_type))
      if current_page_is_common_test_type_page? common_test_type
        haml_concat "|"
        haml_concat link_to_unless_current(t('loinc_codes'), loinc_codes_common_test_type_path(common_test_type))
        haml_concat "|"
        haml_concat link_to_if(common_test_type.lab_results.empty?,
                               t('delete'),
                               common_test_type_path(common_test_type),
                               :method => :delete,
                               :confirm => t('are_you_sure'))
      end
    end
  end

  def check_box_tag_add_loinc_code(loinc_code)
    check_box_tag("added_loinc_codes[]",
                  loinc_code.id,
                  false,
                  :id => h(loinc_code.loinc_code))
  end

  def check_box_tag_remove_loinc_code(loinc_code)
    check_box_tag("removed_loinc_codes[]",
                  loinc_code.id,
                  false,
                  :id => h(loinc_code.loinc_code))
  end

  def link_to_associated_common_test_type(loinc_code)
    link_to_if(loinc_code.common_test_type,
               h(loinc_code.common_test_type.try(:common_name)),
               loinc_code.common_test_type)
  end

  def current_page_is_common_test_type_page?(ctt)
    [common_test_types_path,
     common_test_type_path(ctt),
     edit_common_test_type_path(ctt),
     update_loincs_common_test_type_path(ctt),
     loinc_codes_common_test_type_path(ctt)
    ].any? do |path|
      current_page? path
    end
  end

end
