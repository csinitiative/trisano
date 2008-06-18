class CliniciansController < ApplicationController

  before_filter :get_cmr

  def index
    # No-op -- Debt? Return status code
  end

  def show
    # No-op -- Debt? Return status code
  end

  def new
    @clinician = Entity.new(:person => {},
      :entities_location => { :entity_location_type_id => Code.unspecified_location_id,
        :primary_yn_id => Code.yes_id }
    ) 
    render :layout => false
  end

  def edit
    @clinician = @event.clinicians.find(params[:id])
    render :layout => false
  end

  def create
    @clinician = Participation.new(:role_id => Event.participation_code('Treated By'), :active_secondary_entity => params[:entity])

    if (@event.clinicians << @clinician)
      render(:update) do |page|
        page.replace_html "clinicians-list", :partial => 'clinicians/index'
        page.call "RedBox.close"
      end
    else
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@clinician.active_secondary_entity.person.errors.full_messages}"
      end
    end
  end

  def update
    @clinician = @event.clinicians.find(params[:id])

    if @clinician.active_secondary_entity.update_attributes(params[:entity])
      render(:update) do |page|
        page.replace_html "clinicians-list", :partial => 'clinicians/index'
        page.call "RedBox.close"
      end
    else
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@clinician.active_secondary_entity.person.errors.full_messages}"
      end
    end
  end

  def destroy
    # No-op -- Debt? Return status code
  end
  
  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
  
end
