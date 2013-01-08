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

module PlaceEventsHelper
  extensible_helper

  def place_event_tabs
    event_tabs_for :place_event
  end

  def place_edit_search_js
    <<-SCRIPT
    <script type='text/javascript'>
    $j(function() {
      $j('#new-place-for-event').click(function(evt) {
        evt.preventDefault();
        $j("#place-search").show();
      });

      $j('#close-place-search').click(function(evt) {
        evt.preventDefault();
        $j("#place-search").hide();
      });

      $j('#new_place').submit(function (evt) {
        evt.preventDefault();
        $j('#place_search').trigger('click');
      });
    });
    </script>
    SCRIPT
  end

  def place_search_interface(event)
    search_interface(:places, {
      :label_name => :place_name,
      :results_action => :new,
      :parent_id => event.parent_id,
      :with_types => 'place[place_type_ids][]'
    })
  end
end
