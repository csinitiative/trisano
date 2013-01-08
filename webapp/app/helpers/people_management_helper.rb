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

module PeopleManagementHelper
  extensible_helper

  def render_person_management_list
    render(:partial => 'people/people_list')
  end

  def render_person_actions(person)
    render_actions(person_actions(person))
  end

  def person_actions(person)
    returning [] do |actions|
      actions << link_to(t('edit'), edit_person_path(person.entity_id))
      actions << link_to(t('show'), person_path(person.entity_id))
      if User.current_user.can_create?
        actions << link_to(t('create_cmr_this_person'),
                           cmrs_path(:from_person => person.entity_id,
                                     :return => true),
                           :method => :post)
      end
    end
  end

  def search_result_has_address?(record)
    [:street_number,
     :street_name,
     :unit_number,
     :city,
     :state_name,
     :postal_code].any? {|f| record[f]}
  end

  def search_result_has_second_address_block?(record)
    [:city,
     :state_name,
     :postal_code].any? {|f| record[f]}
  end

  def sortable_column_header(name, property=nil)
    property ||= name
    direction = if params[:sort_order] && params[:sort_order].match(/^#{property.to_s}/)
      (params[:sort_order].match(/asc$/i)) ? 'DESC' : 'ASC'
    else
      'ASC'
    end

    link_to t(name), people_path(request.query_parameters.merge({ :sort_order => "#{property} #{direction}" }))
  end

end
