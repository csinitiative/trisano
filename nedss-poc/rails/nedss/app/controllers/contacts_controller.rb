class ContactsController < ApplicationController

  before_filter :get_cmr

  # GET /lab_results
  # GET /lab_results.xml
  def index
    @lab_results = LabResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lab_results }
    end
  end

  # GET /lab_results/1
  # GET /lab_results/1.xml
  def show
    @lab_result = LabResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lab_result }
    end
  end

  # GET /lab_results/new
  # GET /lab_results/new.xml
  def new
#    @contact = Participation.new(:role_id => Event.participation_code('Contact'),
#                                 :active_secondary_entity => { :person => {},
#                                                               :entities_location => { :entity_location_type_id => Code.unspecified_location_id,
#                                                                                       :primary_yn_id => Code.yes_id }
#                                                             }
#                                ) 
    
    @contact = Entity.new(:person => {},
                          :entities_location => { :entity_location_type_id => Code.unspecified_location_id,
                                                  :primary_yn_id => Code.yes_id }
                         ) 
    render :layout => false
  end

  # GET /lab_results/1/edit
  def edit
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])
    render :layout => false
  end

  # POST /lab_results
  # POST /lab_results.xml
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
        page.call "alert", "Validation failed: #{@participations_treatments.errors.full_messages}"
      end
    end
  end

  # PUT /lab_results/1
  # PUT /lab_results/1.xml
  def update
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])

    if @participations_treatment.update_attributes(params[:participations_treatment])
      render(:update) do |page|
        page.replace_html "treatment-list", :partial => 'index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@participations_treatments.errors.full_messages}"
      end
    end
  end

  # DELETE /lab_results/1
  # DELETE /lab_results/1.xml
  def destroy
    @lab_result = LabResult.find(params[:id])
    @lab_result.destroy

    respond_to do |format|
      format.html { redirect_to(lab_results_url) }
      format.xml  { head :ok }
    end
  end

  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
end
