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
  
  def new
    @event = AssessmentEvent.new

    prepopulate unless params[:from_search].nil?

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def event_search
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_view_privs") }, :status => 403 and return
    end

    @search_form = NameAndBirthdateSearchForm.new(params)
    @event_type = "assessment event"
    @form_target = event_search_aes_path 
    @new_event_link_text = t("start_an_ae")
    @new_event_link_path = new_ae_path(:from_search => "1", :first_name => params[:first_name], :last_name => params[:last_name], :birth_date => params[:birth_date])
    @new_event_link_html_options = {:id => "start_ae"}

    if @search_form.valid?
      if @search_form.has_search_criteria?
        logger.debug "S@search_form.to_hash = #{@search_form.to_hash.inspect}"
        @results = HumanEvent.find_by_name_and_bdate(@search_form.to_hash).paginate(:page => params[:page], :per_page => params[:per_page] || 25)
      end
      render :template => 'search/event_search'
    else
      render :template => 'search/event_search', :status => :unprocessable_entity
    end
  end
  
  private

  def prepopulate
    @event = setup_human_event_tree(@event)
    # Perhaps include a message if we know the names were split out of a full text search
    @event.interested_party.person_entity.person.first_name = params[:first_name]
    @event.interested_party.person_entity.person.middle_name = params[:middle_name]
    @event.interested_party.person_entity.person.last_name = params[:last_name]
    @event.interested_party.person_entity.person.birth_gender = ExternalCode.find(params[:gender]) unless params[:gender].blank? || params[:gender].to_i == 0
    @event.address.city = params[:city]
    @event.address.county = ExternalCode.find(params[:county]) unless params[:county].blank?
    @event.interested_party.person_entity.person.birth_date = params[:birth_date]
  end
end
