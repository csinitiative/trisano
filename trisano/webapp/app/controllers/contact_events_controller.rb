class ContactEventsController < EventsController

  def auto_complete_for_lab_name
    entered_name = params[:contact_event][:new_lab_attributes].first[:name]
    @items = Place.find(:all, :select => "DISTINCT ON (entity_id) entity_id, name", 
      :conditions => [ "LOWER(name) LIKE ? and place_type_id IN 
                       (SELECT id FROM codes WHERE code_name = 'placetype' AND the_code = 'L')", entered_name.downcase + '%'],
      :order => "entity_id, created_at ASC, name ASC",
      :limit => 10
    )
    render :inline => '<ul><% for item in @items %><li id="lab_name_id_<%= item.entity_id %>"><%= h item.name %></li><% end %></ul>'
  end

  def index
    render :text => "Contacts can only be listed from the morbidity event show page of individuals who have contacts.", :status => 405
  end

  def show
    # @event initialized in can_view? filter

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    render :text => "Contacts can only be created from within a morbidity event.", :status => 405
  end

  def edit
    # Filter #can_update? is called which loads up @event with the found event. Nothing to do here.
  end

  def create
    render :text => "Contacts can only be created from within a morbidity event.", :status => 405
  end

  def update
    params[:contact_event][:existing_lab_attributes] ||= {}
    params[:contact_event][:existing_hospital_attributes] ||= {}
    params[:contact_event][:existing_diagnostic_attributes] ||= {}
    params[:contact_event][:existing_telephone_attributes] ||= {}

    respond_to do |format|
      if @event.update_attributes(params[:contact_event])
        flash[:notice] = 'Contact event was successfully updated.'
        format.html { redirect_to(contact_event_url(@event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    head :method_not_allowed
  end

end
