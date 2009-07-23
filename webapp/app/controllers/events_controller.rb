# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class EventsController < ApplicationController

  before_filter :can_update?, :only => [:edit, :update, :destroy, :soft_delete, :event_type]
  before_filter :can_new?, :only => [:new]
  before_filter :can_view?, :only => [:show, :export_single]
  before_filter :can_index?, :only => [:index, :export]
  before_filter :set_tab_index
  
  def auto_complete_for_lab_name
    @items = Place.find(:all, :select => "DISTINCT ON (LOWER(TRIM(name))) name", 
      :include => [:place_types, :entity],
      :conditions => [ "LOWER(name) LIKE ? and codes.code_name = 'placetype' AND codes.the_code = 'L' AND entities.deleted_at IS NULL", params[:lab_name].downcase + '%'],
      :order => "LOWER(TRIM(name)) ASC",
      :limit => 20
    )
    render :inline => "<%= auto_complete_result(@items, 'name') %>"
  end

  def auto_complete_for_test_type
    @items = ExternalCode.find(:all,
      :conditions => ["LOWER(code_description) LIKE ? AND code_name = 'lab_test_type'", '%' + params[:test_type].downcase + '%'],
      :order => "code_description",
      :limit => 20
    )
    render :inline => "<%= auto_complete_result(@items, 'code_description') %>"
  end

  def auto_complete_for_lab_result
    @items = ExternalCode.find_by_sql(["SELECT DISTINCT on (LOWER(TRIM(lab_result_text))) lab_result_text 
                                        FROM lab_results 
                                        WHERE LOWER(lab_result_text) LIKE ? 
                                        ORDER BY LOWER(TRIM(lab_result_text)) 
                                        LIMIT 20", 
        '%' + params[:lab_result].downcase + '%'])

    render :inline => "<%= auto_complete_result(@items, 'lab_result_text') %>"
  end

  def auto_complete_for_treatment
    @items = ExternalCode.find_by_sql(["SELECT DISTINCT on (treatment) treatment 
                                        FROM participations_treatments 
                                        WHERE LOWER(treatment) LIKE ? 
                                        ORDER BY treatment 
                                        LIMIT 20", 
        '%' + params[:treatment].downcase + '%'])

    render :inline => "<%= auto_complete_result(@items, 'treatment') %>"
  end

  def auto_complete_for_clinicians_search
    @clinicians = Person.find(:all, 
                              :conditions => ["LOWER(last_name) LIKE ? AND person_type = 'clinician'", params[:last_name].downcase + '%'],
                              :order => "last_name, first_name",
                              :limit => 20)
    render :partial => "events/clinicians_search", :layout => false, :locals => {:clinicians => @clinicians}
  end

  def contacts_search
    @events = HumanEvent.search_by_name(params[:name])
    render :partial => "events/contacts_search", :layout => false
  end

  def clinicians_search_selection
    clinician_entity = PersonEntity.find(params[:id])
    @clinician = Clinician.new
    @clinician.person_entity = clinician_entity
    render :partial => "events/clinician_show", :layout => false, :locals => { :event_type => params[:event_type] }
  end
  
  def auto_complete_for_places_search
    places_by_name_and_types(params[:place_name], Place.epi_type_codes)
    render :partial => "events/places_search", :layout => false, :locals => {:places => @places}
  end

  def places_search_selection
    place_entity = PlaceEntity.find(params[:id])
    @place = PlaceEvent.new
    @place.build_interested_place
    @place.interested_place.place_entity = place_entity
    @place.build_participations_place

    render :partial => "events/place_exposure_show", :layout => false, :locals => {:event_type => params[:event_type]} 
  end

  def auto_complete_for_diagnostics_search
    places_by_name_and_types(params[:place_name], Place.diagnostic_type_codes)
    render :partial => "events/places_search", :layout => false, :locals => {:places => @places}
  end

  def diagnostics_search_selection
    diagnostic_entity = PlaceEntity.find(params[:id])
    @diagnostic = DiagnosticFacility.new
    @diagnostic.place_entity = diagnostic_entity
    render :partial => "events/diagnostic_show", :layout => false, :locals => {:event_type => params[:event_type]} 
  end

  def auto_complete_for_reporting_agency_search
    places_by_name_and_types(params[:place_name], Place.agency_type_codes)
    render :partial => 'events/reporting_agency_choices', :layout => false, :locals => {:places => @places}
  end

  def reporting_agency_search_selection
    place_entity = PlaceEntity.find(params[:id])
    agency = ReportingAgency.new
    agency.place_entity = place_entity
    render(:update) { |page| page.update_reporting_agency(agency) }
  end
    
  # This action is for development/testing purposes only.  This is not a "real" login action
  def change_user
    auth_allow_user_switch = config_option(:auth_allow_user_switch)

    if auth_allow_user_switch == true
      session[:user_id] = params[:user_id]
      User.current_user = User.find_by_uid(params[:user_id])
      
      redirect_to request.env["HTTP_REFERER"]
    else
      render :text => "Action not available", :status => 403
    end
  end

  def soft_delete
    if @event.soft_delete
      flash[:notice] = 'The event was successfully marked as deleted.'
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:error] = 'An error occurred marking the event as deleted.'
      redirect_to request.env["HTTP_REFERER"]
    end
  end

  def lab_form
    lab = Lab.new
    lab.build_place_entity
    lab.place_entity.build_place
    lab.lab_results.build
    render :partial => 'events/lab', :object => lab, :locals => {:prefix => params[:prefix]}
  end
  
  def lab_result_form
    render :partial => 'events/lab_result', :object => LabResult.new, :locals => {:prefix => params[:prefix]}
  end

  # Route an event from one jurisdiction to another
  def jurisdiction
    @event = Event.find(params[:id])
    begin
      @event.assign_to_lhd params[:jurisdiction_id], params[:secondary_jurisdiction_ids] || [], params[:note]
      @event.reset_to_new if @event.primary_jurisdiction.name == 'Unassigned'
      @event.save!
    rescue Exception => e
      if @event.halted?
        render :partial => "events/permission_denied", :locals => { :reason => e.message, :event => @event }, :status => 403, :layout => true and return
      else
        flash[:error] = 'Unable to route CMR. ' + e.message
        redirect_to request.env["HTTP_REFERER"]
        return
      end
    end
     if User.current_user.is_entitled_to_in?(:view_event, params[:jurisdiction_id]) or
 	         User.current_user.is_entitled_to_in?(:view_event, params[:secondary_jurisdiction_ids])
      flash[:notice] = 'Event successfully routed.'
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:notice] = "Event successfully routed, but you have insufficent privileges to view it in it's new jurisdiction"
      redirect_to cmrs_url
    end
  end

  def state
    @event = Event.find(params[:id])
    workflow_action = params[:morbidity_event].delete(:workflow_action)

    # Squirrel any notes away
    note = params[:morbidity_event].delete(:note)
    
    begin      
      # A status change may be accompanied by other values such as an
      # event queue, set them
      @event.attributes = params[:morbidity_event]
      @event.send(workflow_action, note)
    rescue Exception => e
      # grr. workflow halt exception doesn't work as documented
      if @event.halted?
        render :partial => "events/permission_denied", :locals => { :reason => e.message, :event => nil }, :layout => true, :status => 403 and return
      else
        render :text => "Illegal State Transition", :status => 409 and return
      end
    end
    
    if @event.save
      flash[:notice] = 'Event successfully routed'
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:error] = 'Unable to change state of CMR.'
      redirect_to cmrs_path
    end
  end

  private
  
  def can_update?
    @event ||= Event.find(params[:id])
    unless User.current_user.is_entitled_to_in?(:update_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => "You do not have update privileges for this jurisdiction", :event => @event }, :status => 403 and return
    end
    reject_if_wrong_type(@event)
  end

  def can_new?
    unless User.current_user.is_entitled_to?(:create_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => "You do not have privileges to create an event" }, :status => 403 and return
    end
  end

  def can_index?
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => "You do not have privileges to view events" }, :status => 403 and return
    end
  end
  
  def can_view?
    @event = Event.find(params[:id])
    @display_view_warning = false
    reject_if_wrong_type(@event)
    unless User.current_user.is_entitled_to_in?(:view_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      @display_view_warning = true
      @event.add_note("Extra-jurisdictional, view-only access")
      return
    end
  end

  def reject_if_wrong_type(event)
    if event.read_attribute('type') != controller_name.classify
      respond_to do |format|
        format.html { render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return }
        format.all { render :nothing => true, :status => 404 and return }
      end
    end
  end

  def set_tab_index
    @tab_index = params[:tab_index] || 0
  end

  def places_by_name_and_types(name, type_array)
    @places = Place.find(:all, :select => "DISTINCT ON (LOWER(TRIM(places.name)), codes.id) places.entity_id, places.name, codes.id",
      :include => [:place_types, :entity],
      :conditions => [ "LOWER(places.name) LIKE ? AND codes.code_name = 'placetype' AND codes.the_code IN (#{type_array.to_list}) AND entities.deleted_at IS NULL", name.downcase + '%'],
      :order => "LOWER(TRIM(name)) ASC",
      :limit => 20
    )
  end
end
