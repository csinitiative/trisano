class TreatmentsController < ApplicationController

  before_filter :get_cmr

  # GET /treatments
  # GET /treatments.xml
  def index
    @treatments = Treatment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @treatments }
    end
  end

  # GET /treatments/1
  # GET /treatments/1.xml
  def show
    @treatment = Treatment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @treatment }
    end
  end

  # GET /treatments/new
  # GET /treatments/new.xml
  def new
    @participations_treatment = ParticipationsTreatment.new
    render :layout => false
  end

  # GET /treatments/1/edit
  def edit
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])
    render :layout => false
  end

  # POST /treatments
  # POST /treatments.xml
  def create
    @participations_treatment = ParticipationsTreatment.new(params[:participations_treatment])

    if (@event.active_patient.participations_treatments << @participations_treatment)
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

  # PUT /treatments/1
  # PUT /treatments/1.xml
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

  # DELETE /treatments/1
  # DELETE /treatments/1.xml
  def destroy
    @treatment = Treatment.find(params[:id])
    @treatment.destroy

    respond_to do |format|
      format.html { redirect_to(treatments_url) }
      format.xml  { head :ok }
    end
  end

  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
end
