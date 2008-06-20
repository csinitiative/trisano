class TreatmentsController < ApplicationController

  before_filter :get_cmr

  # GET /treatments
  def index
    @participations_treatments = @event.active_patient.participations_treatments.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /treatments/1
  def show
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /treatments/new
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
  def create
    @participations_treatment = ParticipationsTreatment.new(params[:participations_treatment])

    if (@event.active_patient.participations_treatments << @participations_treatment)
      render(:update) do |page|
        page.replace_html "treatment-list", :partial => 'treatments/index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@participations_treatment.errors.full_messages}"
      end
    end
  end

  # PUT /treatments/1
  def update
    @participations_treatment = @event.active_patient.participations_treatments.find(params[:id])

    if @participations_treatment.update_attributes(params[:participations_treatment])
      render(:update) do |page|
        page.replace_html "treatment-list", :partial => 'treatments/index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@participations_treatment.errors.full_messages}"
      end
    end
  end

  # DELETE /treatments/1
  def destroy
    head :method_not_allowed
  end

  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
end
