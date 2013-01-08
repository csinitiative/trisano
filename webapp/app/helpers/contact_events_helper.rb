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

module ContactEventsHelper
  extensible_helper

  def contact_event_tabs
    event_tabs_for :contact_event
  end

  def expire_event_caches()
    if params['expire_cache_all']
      redis.delete_matched("views/events/#{@event.id}/*")
    elsif params['expire_cache']
      params['expire_cache'].each do |key, value|
        redis.delete_matched("views/events/#{@event.id}/edit/#{key}*")
        redis.delete_matched("views/events/#{@event.id}/show/#{key}*")
        redis.delete_matched("views/events/#{@event.id}/showedit/#{key}*")
      end
    end
  end

  def contact_edit_search_js
    <<-SCRIPT
    <script type='text/javascript'>
    $j(function() {
      $j('#new-contact-for-event').click(function(evt) {
        evt.preventDefault();
        $j("#contact-search").show();
      });

      $j('#close-contact-search').click(function(evt) {
        evt.preventDefault();
        $j("#contact-search").hide();
      });
    });
    </script>
    SCRIPT
  end
end
