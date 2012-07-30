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

RoutingStruct = Struct.new(:jurisdiction_id, :note)

class EventsController < ApplicationController
  before_filter :can_update?, :only => [:edit, :update, :destroy, :soft_delete, :event_type]
  before_filter :can_new?, :only => [:new, :create]
  before_filter :can_view?, :only => [:show, :export_single]
  before_filter :can_index?, :only => [:index, :export]
  before_filter :can_access_sensitive?, :only => [:edit, :show, :update, :destroy, :soft_delete]
  before_filter :set_tab_index
  before_filter :update_last_modified_date, :only => [:update]
  before_filter :find_or_build_event, :only => [ :reporters_search_selection, :reporting_agencies_search, :reporting_agency_search_selection ]
  before_filter :can_promote?, :only => :event_type
  before_filter :load_event_queues, :only => [:index]

  def index
    return unless index_processing
    @event_states_and_descriptions = Event.get_all_states_and_descriptions

    respond_to do |format|
      format.html
      format.xml  { render :xml => @events }
      format.csv
    end
  end

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
    clinician_entity = PersonEntity.find(params[:id])
    @clinician = Clinician.new
    @clinician.person_entity = clinician_entity
    render :partial => "events/clinician_show", :layout => false, :locals => { :event_type => params[:event_type] }
  end

  def reporter_search_selection
    @event = Event.find params[:event_id]
    @event.build_reporter :secondary_entity_id => params[:id]
    render :partial => "events/reporter_from_search", :layout => false
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

    render :partial => "events/place_exposure_show", :layout => false, :locals => {:event_type => params[:event_type].underscore}
  end

  def clinicians_search
    page = params[:page] || 1
    name = (params[:name] || '').strip
    begin
      @clinicians = Person.active.send(:clinicians).find(:all,
      :conditions => ["(LOWER(last_name) LIKE ? OR LOWER(first_name) LIKE ?)", name.downcase + '%', name.downcase + '%']).paginate(:include => {:person_entity => :telephones}, :page => page, :per_page => 10)
    rescue
      logger.error($!)
      flash.now['error'] = t('invalid_search_criteria')
      @clinicians = []
    end
    render :partial => "events/clinicians_search", :layout => false
  end

  def reporters_search
    @event = Event.find(params[:event_id])
    page = params[:page] || 1
    name = (params[:name] || '').strip
    begin
      @reporters = Person.active.send(:reporters).find(:all,
      :conditions => ["(LOWER(last_name) LIKE ? OR LOWER(first_name) LIKE ?)", name.downcase + '%', name.downcase + '%']).paginate(:include => {:person_entity => :telephones}, :page => page, :per_page => 10)
    rescue
      logger.error($!)
      flash.now['error'] = t('invalid_search_criteria')
      @reporters = []
    end
    render :partial => "events/reporters_search", :layout => false
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
    render :partial => "events/diagnostic", :layout => false, :locals => {:event_type => params[:event_type]}
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
    if @event.reporting_agency.nil?
      @event.build_reporting_agency :secondary_entity_id => params[:id]
    else
      @event.reporting_agency.secondary_entity_id = params[:id]
    end
    render :layout => false
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

  def edit_jurisdiction
    respond_to do |format|
      format.xml do
        @event = Event.find params[:id]
        @routing = RoutingStruct.new
        @routing.jurisdiction_id = @event.jurisdiction.secondary_entity_id if @event.jurisdiction
        @routing.note = ''
      end
    end
  end

  # Route an event from one jurisdiction to another
  def jurisdiction
    @event = Event.find(params[:id])
    begin
      # Debt: be nice to have to only call one method to route
      Event.transaction do
        @event.assign_to_lhd params[:routing][:jurisdiction_id], params[:secondary_jurisdiction_ids] || [], params[:routing][:note]
        @event.reset_to_new if @event.jurisdiction.place.is_unassigned_jurisdiction?
        @event.save!
      end
    rescue Exception => e
      # DEBT: The :no_jurisdiction_change halted_because value is set
      # at lib/routing/workflow_helper.rb:41. However, in some cases,
      # this method is never called. For example, if the
      # jurisdiction_id field is invalid (not a legitimate place
      # entity), an exception is raised within the Workflow module
      # before assign_to_lhd is called. We do not seem to have direct
      # control over that field, which in that instance is a string
      # like "Couldn't find PlaceEntity with ID=721." The exceptions
      # are not distinguished by class either. The only immediate way
      # to distinguish these cases is by parsing this string in one
      # place or another.

      if @event.halted? && @event.halted_because =~ /^Couldn't find PlaceEntity with ID=/
        respond_to do |format|
          # DEBT: Respond to HTML? This can't happen, since the user
          # is given a drop-down list of place entities.
          format.xml do
            @event.errors.add(:jurisdiction_id, @event.halted_because)
            render :xml => @event.errors, :status => :unprocessable_entity
          end
        end
      elsif @event.halted? && @event.halted_because != :no_jurisdiction_change
        respond_to do |format|
          format.html do
            render :partial => "events/permission_denied", :locals => { :reason => e.message, :event => @event }, :status => 403, :layout => true
          end
          format.xml { render :xml => @event.errors, :status => :forbidden }
        end
      else
        if User.current_user.can_update?(@event)
          respond_to do |format|
            format.html do
              flash.now[:error] = t("unable_to_route_cmr", :message => e.message)
              render :action => :edit, :status => :bad_request
            end
            format.xml { render :xml => @event.errors, :status => :bad_request }
          end
        else
          respond_to do |format|
            format.html do
              flash[:error] = t(:unable_to_route_cmr_no_edit_priv, :message => e.message)
              redirect_to :back
            end
            format.xml { render :xml => @event.errors, :status => :forbidden }
          end
        end
      end
      return
    end

    respond_to do |format|
      format.html do
        if User.current_user.is_entitled_to_in?(:view_event, params[:routing][:jurisdiction_id]) or
            User.current_user.is_entitled_to_in?(:view_event, params[:secondary_jurisdiction_ids])
          flash[:notice] = t("event_successfully_routed")
          redirect_to :back
        else
          flash[:notice] = t("event_successfully_routed_no_privs")
          redirect_to events_path
        end
      end
      format.xml { head :ok }
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
        logger.error("Illegal state transition")
        logger.error(e.message)
        flash[:error] = "Event state was modified prior to your action.  Review the event again."
        redirect_to :back and return
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
        redirect_to events_path
      end
    end
  end

  def event_type
    if promoted_event = @event.promote_to(params[:type])
      flash[:notice] = t(:promoted_to, :type => params[:type].humanize.downcase)
      redirect_to @template.event_path(promoted_event)
    else
      flash.now[:error] = t("could_not_promote_event")
      render :action => :edit, :status => :bad_request
    end
  end

  private

  def can_update?
    @event ||= Event.find(params[:id])
    unless User.current_user.can_update?(@event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_update_privs_for_jurisdiction"), :event => @event }, :status => 403 and return
    end
    reject_if_wrong_type(@event)
  end

  def can_new?
    unless User.current_user.can_create?
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_create_privs") }, :status => 403 and return
    end
  end

  def can_index?
    unless User.current_user.can_view?
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_view_privs") }, :status => 403 and return
    end
  end

  def can_view?
    @event ||= Event.find(params[:id])
    @display_view_warning = false
    return if reject_if_wrong_type(@event)
    unless User.current_user.can_view?(@event)
      log_access_or_prompt_for_reason
      return
    end
    stale?(:last_modified => @event.updated_at.utc, :etag => @event) if RAILS_ENV == 'production'
  end

  def can_access_sensitive?
    @event ||= Event.find(params[:id])
    if @event.sensitive? && !User.current_user.can_access_sensitive_diseases?(@event)
      render :file => static_error_page_path(403), :layout => 'application', :status => 403 and return
    end
  end

  def can_create?
    User.current_user.can_create?(@event) && (@event.sensitive? ? User.current_user.can_access_sensitive_diseases?(@event) : true)
  end

  def reject_if_wrong_type(event)
    is_rejected = false
    if event.read_attribute('type') != controller_name.classify
      is_rejected = true
      correct_url = @template.event_path(@event)
      event_link = correct_url ? @template.link_to(correct_url, correct_url) : nil
      respond_to do |format|
        format.html { render :partial => "shared/missing_event", :locals => {:event_link => event_link}, :layout => 'application', :status => 404 }
        format.all { render :nothing => true, :status => 404 }
      end
    end
    is_rejected
  end

  def log_access_or_prompt_for_reason
    access_record = AccessRecord.find_by_user_id_and_event_id(User.current_user.id, @event.id)
    redirect_to(new_event_access_record_path(@event)) and return if access_record.nil?
    access_record.update_attribute(:access_count, access_record.access_count + 1)
    @display_view_warning = true
    @event.add_note(I18n.translate("system_notes.extra_jurisdictional_view_only_access", :locale => I18n.default_locale))
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

  def find_or_build_event
    if params[:event_id]
      @event = Event.find(params[:event_id])
    else
      @event = params[:event_type].camelize.constantize.new
    end
  end

  def update_last_modified_date
    @event.updated_at = DateTime.now
  end

  def load_event_queues
    @event_queues = EventQueue.queues_for_jurisdictions User.current_user.jurisdiction_ids_for_privilege(:view_event)
  end

  def index_processing
    if params[:per_page].to_i > 100
      render :text => t("too_many_cmrs"), :layout => 'application', :status => 400
      return false
    end

    begin
      @export_options = params[:export_options]

      query_options = {
        :event_types => params[:event_types],
        :states => params[:states],
        :queues => params[:queues],
        :investigators => params[:investigators],
        :diseases => params[:diseases],
        :order_direction => params[:sort_direction],
        :do_not_show_deleted => params[:do_not_show_deleted],
        :per_page => params[:per_page]
      }

      @events = MorbidityEvent.find_all_for_filtered_view(query_options.merge({
        :view_jurisdiction_ids => User.current_user.jurisdiction_ids_for_privilege(:view_event),
        :access_sensitive_jurisdiction_ids => User.current_user.jurisdiction_ids_for_privilege(:access_sensitive_diseases),
        :order_by => params[:sort_order],
        :page => params[:page]
      }))

      User.current_user.update_attribute('event_view_settings', query_options) if params[:set_as_default_view] == "1"
    rescue
      render :file => static_error_page_path(404), :layout => 'application', :status => 404
      return false
    end
    return true
  end

end
