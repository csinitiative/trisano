# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
    @can_investigate = can_investigate
    unless User.current_user.is_entitled_to_in?(:update_event, @event.active_jurisdiction.secondary_entity_id)
      render :text => "Permission denied: You do not have update privileges for this jurisdiction", :status => 403
      return
    end
    reject_if_wrong_type(@event)
  end
  
  def can_view?
    @event = Event.find(params[:id])
    @can_investigate = can_investigate
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
  
  def can_investigate
    (
      (@event.under_investigation?) and 
        User.current_user.is_entitled_to_in?(:investigate_event, @event.active_jurisdiction.secondary_entity_id) and 
        (@event.disease && @event.disease.disease_id)
    )
  end

  def prep_multimodels_for(event)
    params[event.to_sym][:existing_lab_attributes] ||= {}
    params[event.to_sym][:existing_hospital_attributes] ||= {}
    params[event.to_sym][:existing_diagnostic_attributes] ||= {}
    params[event.to_sym][:existing_telephone_attributes] ||= {}
    params[event.to_sym][:existing_place_exposure_attributes] ||= {}
  end
  
end
