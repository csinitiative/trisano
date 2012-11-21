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

class MorbidityEventsController < EventsController
  include EventsHelper

  def show
    # @event initialized in can_view? filter
    @export_options = params[:export_options]
    respond_to do |format|
      format.html # show.html.erb
      format.xml
      format.csv
      format.print { @print_options = params[:print_options] || [] }
    end
  end

  def new
    @event = MorbidityEvent.new

    prepopulate unless params[:from_search].nil?

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def edit
    # Via filters above #can_update? is called which loads up @event with the found event.
    # Nothing to do here.
  end

  def create
    go_back = params.delete(:return)

    @event = MorbidityEvent.new
    if params[:from_event]
      org_event = Event.find(params[:from_event])
      components = params[:event_components]
      org_event.copy_event(@event, components || []) # Copy instead of clone to make sure contacts become morbs

      # A little DEBT:  Better to add a column to events that points at the 'parent,' and generate this reference in the view
      @event.add_note(t("system_notes.event_derived_from", :locale => I18n.default_locale, :link => ActionView::Base.new.link_to("Event #{org_event.record_number}", cmr_path(org_event) ))) if components && !components.empty?
    elsif params[:from_person]
      person = PersonEntity.find(params[:from_person])
      @event.copy_from_person(person)
    else
      @event.attributes = params[:morbidity_event]
    end
    unless can_create?
      render :partial => "events/permission_denied", :locals => { :reason => t("no_event_create_privs"), :event => @event }, :layout => true, :status => 403 and return
    end

    respond_to do |format|
      if @event.save
        # Debt:  There's gotta be a better place for this.  Doesn't work on after_save of events.
        Event.transaction do
          [@event, @event.contact_child_events].flatten.all? { |event| event.set_primary_entity_on_secondary_participations }
          @event.add_note(@event.instance_eval(@event.states(@event.state).meta[:note_text]))
        end
    
        # This is required so that repeater answers for hospital participation fields can be
        # established when a hospiatlization facility is created
        @event.hospitalization_facilities.each do |hospital|
          hospital.create_hospitals_participation unless hospital.hospitals_participation
        end
        @event.reload
        @event.create_form_answers_for_repeating_form_elements
        @event.try(:address).try(:establish_canonical_address)
        flash[:notice] = t("cmr_created")
        format.html {
          if go_back
            redirect_to edit_cmr_url(@event, @query_params)
          else
            redirect_to cmr_url(@event, @query_params)
          end
        }
        format.xml { head :created, :location => cmr_url(@event) }
      else
        format.html { render :action => "new", :status => :unprocessable_entity }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    # Per-tab cache expire feature not quite working yet, so expire all.
    #expire_event_caches
    redis.delete_matched("views/events/#{@event.id}/*")

    go_back = params.delete(:return)

    # Do this assign and a save rather than update_attributes in order to get the contacts array (at least) properly built
    @event.update_from_params(params[:morbidity_event])
    @disease_changed = @event.disease_changed?
    # Assume that "save & exits" represent a 'significant' update
    @event.add_note(I18n.translate("system_notes.event_edited", :locale => I18n.default_locale)) unless go_back

    # Eager load answers that already exist so questions won't need to be retrieved 1-by-1
    # during validation on answers on the save
    @event.eager_load_answers
    respond_to do |format|
      if @event.save

        # Debt:  There's gotta be a better place for this.  Doesn't work on after_save of events.
        Event.transaction do
          [@event, @event.contact_child_events].flatten.all? { |event| event.set_primary_entity_on_secondary_participations }
        end

        flash[:notice] = t("cmr_updated")
        format.html {
          if go_back or @disease_changed
            @query_params.merge!({:forms => true}) if @disease_changed
            redirect_to edit_cmr_url(@event, @query_params)
          else
            url = params[:redirect_to]
            url = cmr_url(@event, @query_params) if url.blank?
            redirect_to url
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => t("cmr_saved"), :status => :created }
      else
        format.html { render :action => "edit", :status => :unprocessable_entity }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => t("morbidity_event_not_saved", :message => @event.errors.full_messages), :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    head :method_not_allowed
  end

  def event_search
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => t("no_event_view_privs") }, :status => 403 and return
    end

    @search_form = NameAndBirthdateSearchForm.new(params)
    @event_type = "morbidity event"
    @form_target = event_search_cmrs_path 
    @new_event_form_id = "new_cmr_form"
    @new_event_form_submit_text = t("start_a_cmr")
    @new_event_form_path = new_cmr_path(:from_search => "1")
    @new_event_form_html_options = {:id => "start_cmr"}

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

  # IE can't handle URLs > 2K so we've added a special method that it can POST to.
  def export
    return unless index_processing
    render :action => "index"
  end

  # IE can't handle URLs > 2K so we've added a special method that it can POST to.
  def export_single
    render :action => "show"
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
