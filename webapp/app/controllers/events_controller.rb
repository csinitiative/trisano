# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

  def contacts_search
    page = params[:page] ? params[:page] : 1

    begin
      @results = HumanEvent.find_by_name_and_bdate(
        :fulltext_terms => params[:name],
        :page => page,
        :page_size => 20
      )
    rescue
      flash.now[:error] = t(:invalid_search_criteria)
    end

    render :partial => "events/contacts_search", :layout => false
  end

  def clinicians_search_selection
    clinician_entity = PersonEntity.find(params[:entity_id])
    @clinician = Clinician.new
    @clinician.person_entity = clinician_entity
    render :partial => "events/clinician_show", :layout => false, :locals => { :event_type => params[:event_type] }
  end

  def places_search
    page = params[:page] ? params[:page] : 1
    name = params[:name]
    # DEBT: Sure there must be a better way to parse this.
    type_ids = params[:types].sub(/^\[(.*)\]$/, '\1').split(',').map {|s| s.to_i}
    types = Code.find(type_ids).map{|c|c.the_code}

    types = Place.epi_type_codes if types.blank?

    begin
      @places = Place.starts_with(name).types(types).paginate(:include => { :entity => [:addresses, :canonical_address] }, :page => page, :per_page => 10)
    rescue
      logger.error($!)
      flash.now['error'] = t('invalid_search_criteria')
      @places = []
    end

    render :partial => "events/places_search", :layout => false, :locals => { :places => @places }
  end

  def places_search_selection
    place_entity = PlaceEntity.find(params[:id])
    @place = PlaceEvent.new
    @place.build_interested_place
    @place.interested_place.place_entity = place_entity
    @place.build_participations_place

    render :partial => "events/place_exposure_show", :layout => false, :locals => {:event_type => params[:event_type]}
  end

  def diagnostic_facilities_search
    page = params[:page] || 1
    name = (params[:name] || '').strip
    begin
      @places = Place.diagnostic_facilities(name).paginate(:include => { :entity => [:addresses, :canonical_address] }, :page => page, :per_page => 10)
    rescue
      logger.error($!)
      flash.now['error'] = t('invalid_search_criteria')
      @places = []
    end
    render :partial => "events/diagnostics_search", :layout => false
  end

  def diagnostics_search_selection
    diagnostic_entity = PlaceEntity.find(params[:id])
    @diagnostic = DiagnosticFacility.new
    @diagnostic.place_entity = diagnostic_entity
    render :partial => "events/diagnostic_show", :layout => false, :locals => {:event_type => params[:event_type]}
  end

  def reporting_agencies_search
    page = params[:page] || 1
    name = (params[:name] || '').strip

    begin
      @places = Place.reporting_agencies_by_name(name).paginate(:include => { :entity => [:addresses, :canonical_address] }, :page => page, :per_page => 10)
    rescue
      logger.error($!)
      flash.now['error'] = t('invalid_search_criteria')
      @places = []
    end
    render :partial => "events/reporting_agencies_search", :layout => false
  end

  def reporting_agency_search_selection
    reporting_agency_entity = PlaceEntity.find(params[:id])
    @reporting_agency = ReportingAgency.new
    @reporting_agency.place_entity = reporting_agency_entity
    render :partial => "events/reporting_agency", :layout => false, :locals => {:event_type => params[:event_type]}
  end

  # This action is for development/testing purposes only.  This is not a "real" login action
  def change_user
    auth_allow_user_switch = config_option(:auth_allow_user_switch)

    if auth_allow_user_switch == true
      session[:user_id] = params[:user_id]
      User.current_user = User.find_by_uid(params[:user_id])

      redirect_to request.env["HTTP_REFERER"]
    else
      render :text => t("action_not_avaliable"), :status => 403
    end
  end

  def soft_delete
    if @event.soft_delete
      flash[:notice] = t("successfully_marked_as_deleted")
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:error] = t("error_marking_event_as_deleted")
      redirect_to request.env["HTTP_REFERER"]
    end
  end

  def lab_form
    lab = Lab.new
    lab.build_place_entity
    lab.place_entity.build_place
    lab.lab_results.build

    @disease = params[:disease_id].blank? ? nil : Disease.find(params[:disease_id])
    render :partial => 'events/lab', :object => lab, :locals => {:prefix => params[:prefix] }
  end

  def lab_result_form
    @disease = params[:disease_id].blank? ? nil : Disease.find(params[:disease_id])
    render :partial => 'events/lab_result', :object => LabResult.new, :locals => {:prefix => params[:prefix]}
  end

  def test_type_options
    render :inline => <<-test_opts
      <% test_types = test_type_options(nil, nil, nil) %>
      <option value=""/>
      <%= options_from_collection_for_select(test_types, 'id', 'common_name') %>
    test_opts
  end

  def organism_options
    render :inline => <<-org_opts
      <% org_types = organism_options(nil, nil, nil) %>
      <option value=""/>
      <%= options_from_collection_for_select(org_types, 'id', 'organism_name') %>
    org_opts
  end


  # Route an event from one jurisdiction to another
  def jurisdiction
    @event = Event.find(params[:id])
    begin
      # Debt: be nice to have to only call one method to route
      Event.transaction do
        @event.assign_to_lhd params[:jurisdiction_id], params[:secondary_jurisdiction_ids] || [], params[:note]
        @event.reset_to_new if @event.primary_jurisdiction.is_unassigned_jurisdiction?
        @event.save!
      end
    rescue Exception => e
      # Debt: eh, this could be better
      if @event.halted? && @event.halted_because != :no_jurisdiction_change
        render :partial => "events/permission_denied", :locals => { :reason => e.message, :event => @event }, :status => 403, :layout => true and return
      else
        if User.current_user.can_update?(@event)
          flash.now[:error] = t("unable_to_route_cmr", :message => e.message)
          render :action => :edit, :status => :bad_request
        else
          flash[:error] = t(:unable_to_route_cmr_no_edit_priv, :message => e.message)
          redirect_to :back
        end
        return
      end
    end
    if User.current_user.is_entitled_to_in?(:view_event, params[:jurisdiction_id]) or
        User.current_user.is_entitled_to_in?(:view_event, params[:secondary_jurisdiction_ids])
      flash[:notice] = t("event_successfully_routed")
      redirect_to :back
    else
      flash[:notice] = t("event_successfully_routed_no_privs")
      redirect_to :action => :index
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
        render :text => t("illegal_state_transition"), :status => 409 and return
      end
    end

    if @event.save
      flash[:notice] = t("event_successfully_routed")
      redirect_to :back
    else
      if User.current_user.can_update?(@event)
        flash.now[:error] = t("unable_to_change_cmr_state")
        render :action => :edit, :status => :bad_request
      else
        flash[:error] = t(:unable_to_change_state_no_edit_privs)
        redirect_to :action => :index
      end
    end
  end

  private

  def can_update?
    @event ||= Event.find(params[:id])
    unless User.current_user.is_entitled_to_in?(:update_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_update_privs_for_jurisdiction"), :event => @event }, :status => 403 and return
    end
    reject_if_wrong_type(@event)
  end

  def can_new?
    unless User.current_user.is_entitled_to?(:create_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_create_privs") }, :status => 403 and return
    end
  end

  def can_index?
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_view_privs") }, :status => 403 and return
    end
  end

  def can_view?
    @event = Event.find(params[:id])
    @display_view_warning = false
    reject_if_wrong_type(@event)
    unless User.current_user.is_entitled_to_in?(:view_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      @display_view_warning = true
      @event.add_note(I18n.translate("system_notes.extra_jurisdictional_view_only_access", :locale => I18n.default_locale))
      return
    end
    stale?(:last_modified => @event.updated_at.utc, :etag => @event) if RAILS_ENV == 'production'
  end

  def reject_if_wrong_type(event)
    if event.read_attribute('type') != controller_name.classify
      respond_to do |format|
        format.html { render :file => static_error_page_path(404), :layout => 'application', :status => 404 and return }
        format.all { render :nothing => true, :status => 404 and return }
      end
    end
  end

  def set_tab_index
    @query_params = {}
    @tab_index = 0
    unless params[:tab_index].blank?
      @tab_index = params[:tab_index]
      @query_params[:tab_index] = params[:tab_index]
    end
  end

  # Debt: too fat. needs to be in the place class
  def places_by_name_and_types(name, type_array)
    @places = Place.find(:all, :select => "DISTINCT ON (LOWER(TRIM(places.name)), codes.id) places.entity_id, places.name, codes.id",
      :include => [:place_types, {:entity => [:addresses, :canonical_address]}],
      :conditions => [ "LOWER(places.name) LIKE ? AND codes.code_name = 'placetype' AND codes.the_code IN (#{type_array.to_list}) AND entities.deleted_at IS NULL", name.downcase + '%'],
      :order => "LOWER(TRIM(name)) ASC",
      :limit => 20
    )
  end
end
