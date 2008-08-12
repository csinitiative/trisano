class EventsController < ApplicationController

  before_filter :can_update?, :only => [:edit, :update, :destroy]
  before_filter :can_view?, :only => [:show]
  before_filter :get_investigation_forms, :only => [:edit]
  
  # This action is for development/testing purposes only.  This is not a "real" login action
  def change_user
    if RAILS_ENV == "production"
      render :text => "Action not available", :status => 403
    else
      session[:user_id] = params[:user_id]
      User.current_user = User.find_by_uid(params[:user_id])
      
      render(:update) do |page|
        page.replace_html("user_name", :inline => "<%= User.current_user.user_name %>")
      end
    end
  end
  private
  
  def can_update?
    @event ||= Event.find(params[:id])
    @can_investigate = (
      (@event.under_investigation?) and 
        User.current_user.is_entitled_to_in?(:investigate_event, @event.active_jurisdiction.secondary_entity_id) and 
        (@event.disease && @event.disease.disease_id)
    )
    unless User.current_user.is_entitled_to_in?(:update_event, @event.active_jurisdiction.secondary_entity_id)
      render :text => "Permission denied: You do not have update privileges for this jurisdiction", :status => 403
      return
    end
    reject_if_wrong_type(@event)
  end
  
  def can_view?
    @event = Event.find(params[:id])
    unless User.current_user.is_entitled_to_in?(:view_event, @event.active_jurisdiction.secondary_entity_id)
      render :text => "Permission denied: You do not have view privileges for this jurisdiction", :status => 403
      return
    end
    reject_if_wrong_type(@event)
  end

  def reject_if_wrong_type(event)
    if event.read_attribute('type') != controller_name.classify
      respond_to do |format|
        format.html { render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return }
        format.all { render :nothing => true, :status => 404 and return }
      end
    end
  end

  def get_investigation_forms
    @event ||= Event.find(params[:id])
    @event.get_investigation_forms
  end
  
end
