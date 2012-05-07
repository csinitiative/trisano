# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class AssessmentEventsController < EventsController
  include EventsHelper

  def event_search
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_view_privs") }, :status => 403 and return
    end

    @search_form = NameAndBirthdateSearchForm.new(params)

    if @search_form.valid?
      if @search_form.has_search_criteria?
        logger.debug "S@search_form.to_hash = #{@search_form.to_hash.inspect}"
        @results = HumanEvent.find_by_name_and_bdate(@search_form.to_hash).paginate(:page => params[:page], :per_page => params[:per_page] || 25)
      end
    else
      render :action => :event_search, :status => :unprocessable_entity
    end
  end
end
