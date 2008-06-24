class HealthFacilitiesController < ApplicationController

  before_filter :get_cmr

  def index
    head :method_not_allowed
  end

  def show
    head :method_not_allowed
  end

  def new
    if params[:role_id].blank?
      head :bad_request 
      return
    end
    
    @health_facility = Participation.new( :role_id => params[:role_id], :hospitals_participation => {}, :active_secondary_entity => { :place => {} })
    render :layout => false
  end

  def edit
    if params[:role_id].blank?
      head :bad_request 
      return
    end
    health_facility_association, refresh_list = get_role_specific_values(params[:role_id])
    @health_facility = health_facility_association.find(params[:id])
    render :layout => false
  end

  def create
    if params[:health_facility][:role_id].blank?
      head :bad_request 
      return
    end
    
    @health_facility = Participation.new(params[:health_facility])
    
    health_facility_association, refresh_list = get_role_specific_values(params[:health_facility][:role_id])
    
    if (health_facility_association << @health_facility)
      render(:update) do |page|
        page.replace_html refresh_list, :partial => 'health_facilities/index', :locals => { :health_facilities => health_facility_association, :refresh_list => refresh_list }
        page.call "RedBox.close"
      end
    else
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@health_facility.errors.full_messages}"
      end
    end
  end

  def update
    if params[:health_facility][:role_id].blank?
      head :bad_request 
      return
    end
    
    health_facility_association, refresh_list = get_role_specific_values(params[:health_facility][:role_id])
    
    @health_facility = health_facility_association.find(params[:id])

    if @health_facility.update_attributes(params[:health_facility])
      render(:update) do |page|
        page.replace_html refresh_list, :partial => 'health_facilities/index', :locals => { :health_facilities => health_facility_association, :refresh_list => refresh_list }
        page.call "RedBox.close"
      end
    else
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@health_facility.errors.full_messages}"
      end
    end
  end

  def destroy
    head :method_not_allowed
  end
  
  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
  
  def get_role_specific_values(role_id)
    if (role_id == Code.find_by_code_name_and_code_description('participant', "Diagnosed At").id.to_s)
      health_facility_association = @event.diagnosing_health_facilities
      refresh_list = "diagnosing-health-facilities-list"
    else
      health_facility_association = @event.hospitalized_health_facilities
      refresh_list = "hospitalized-health-facilities-list"
    end
    return health_facility_association, refresh_list
  end
  
end
