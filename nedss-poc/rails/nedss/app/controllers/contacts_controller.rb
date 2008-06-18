class ContactsController < ApplicationController

  before_filter :get_cmr

  # GET /contacts
  # GET /contacts.xml
  def index
    @contacts = @event.contacts.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @contact = @event.contacts.find(params[:id])
    render(:update) do |page|
      page.show "contact-detail"
      page.replace_html "contact-detail", :partial => 'show'
    end

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @contact }
    # end
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contact = Entity.new(:person => {},
                          :entities_location => { :entity_location_type_id => Code.unspecified_location_id,
                                                  :primary_yn_id => Code.yes_id }
                         ) 
    render :layout => false
  end

  # GET /contacts/1/edit
  def edit
    @contact = @event.contacts.find(params[:id])
    render :layout => false
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Participation.new(:role_id => Event.participation_code('Contact'), :active_secondary_entity => params[:entity])

    if (@event.contacts << @contact)
      render(:update) do |page|
        page.replace_html "contact-list", :partial => 'index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@contact.active_secondary_entity.person.errors.full_messages}"
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = @event.contacts.find(params[:id])

    if @contact.active_secondary_entity.update_attributes(params[:entity])
      render(:update) do |page|
        page.replace_html "contact-list", :partial => 'index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@contact.active_secondary_entity.person.errors.full_messages}"
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = FIX THIS LabResult.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end

  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
end
