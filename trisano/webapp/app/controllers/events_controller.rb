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

  before_filter :can_update?, :only => [:edit, :update, :destroy, :soft_delete]
  before_filter :can_view?, :only => [:show]
  before_filter :get_investigation_forms, :only => [:edit, :show]
  before_filter :set_tab_index
  
  def auto_complete_for_lab_name
    @items = Place.find(:all, :select => "DISTINCT ON (entity_id) entity_id, name", 
      :conditions => [ "LOWER(name) LIKE ? and place_type_id IN 
                       (SELECT id FROM codes WHERE code_name = 'placetype' AND the_code = 'L')", params[:lab_name].downcase + '%'],
      :order => "entity_id, created_at ASC, name ASC",
      :limit => 10
    )
    render :inline => "<%= auto_complete_result(@items, 'name') %>"
  end

  def auto_complete_for_test_type
    # acts_as_auditable code getting in the way of this.
    # @items = ExternalCode.find(:all,
    #   :conditions => ["LOWER(code_description) LIKE ? AND code_name = 'gender'", '%' + params[:test_type].downcase + '%'],
    #   :order => "code_description",
    #   :limit => 10
    # )
    
    @items = ExternalCode.find_by_sql(["SELECT code_description 
                                        FROM external_codes 
                                        WHERE LOWER(code_description) LIKE ? 
                                        AND code_name = 'lab_test_type' 
                                        ORDER BY sort_order 
                                        LIMIT 10", 
                                        '%' + params[:test_type].downcase + '%'])

    render :inline => "<%= auto_complete_result(@items, 'code_description') %>"
  end

  def auto_complete_for_lab_result
    @items = ExternalCode.find_by_sql(["SELECT DISTINCT on (lab_result_text) lab_result_text 
                                        FROM lab_results 
                                        WHERE LOWER(lab_result_text) LIKE ? 
                                        ORDER BY lab_result_text 
                                        LIMIT 10", 
                                        '%' + params[:lab_result].downcase + '%'])

    render :inline => "<%= auto_complete_result(@items, 'lab_result_text') %>"
  end

  def auto_complete_for_treatment
    @items = ExternalCode.find_by_sql(["SELECT DISTINCT on (treatment) treatment 
                                        FROM participations_treatments 
                                        WHERE LOWER(treatment) LIKE ? 
                                        ORDER BY treatment 
                                        LIMIT 10", 
                                        '%' + params[:treatment].downcase + '%'])

    render :inline => "<%= auto_complete_result(@items, 'treatment') %>"
  end

  def auto_complete_for_clinicians_search
    sql = <<-SQL
      SELECT DISTINCT ON (l.id) l.id, l.last_name, l.first_name, l.middle_name, l.entity_id 
      FROM participations p 
        LEFT OUTER JOIN people l ON (p.secondary_entity_id = l.entity_id)
      WHERE p.role_id = ? and LOWER(l.last_name) LIKE ?
    SQL
    @clinicians = Person.find_by_sql([sql, Code.treated_by_type_id, params[:last_name].downcase + '%'])
    render :partial => "events/clinicians_search", :layout => false, :locals => {:clinicians => @clinicians}
  end

  def clinicians_search_selection
    @clinician = Person.find(params[:id])
    render :partial => "events/clinician_show", :layout => false, :locals => {:clinician_show => @clinician} 
  end

  # This action is for development/testing purposes only.  This is not a "real" login action
  def change_user
    if RAILS_ENV == "production"
      render :text => "Action not available", :status => 403
    else
      session[:user_id] = params[:user_id]
      User.current_user = User.find_by_uid(params[:user_id])
      
      redirect_to request.env["HTTP_REFERER"]
    end
  end

  def soft_delete
    if @event.soft_delete
      @event.add_note("Deleted event.")
      flash[:notice] = 'The event was successfully marked as deleted.'
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:error] = 'An error occurred marking the event as deleted.'
      redirect_to request.env["HTTP_REFERER"]
    end
  end

  private
  
  def can_update?
    @event ||= Event.find(params[:id])
    @can_investigate = can_investigate
    unless User.current_user.is_entitled_to_in?(:update_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :text => "Permission denied: You do not have update privileges for this jurisdiction", :status => 403
      return
    end
    reject_if_wrong_type(@event)
  end
  
  def can_view?
    @event = Event.find(params[:id])
    @can_investigate = can_investigate
    unless User.current_user.is_entitled_to_in?(:view_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
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
      User.current_user.is_entitled_to_in?(:investigate_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } ) and
        (@event.disease && @event.disease.disease_id)
    )
  end

  def set_tab_index
    @tab_index = params[:tab_index] || 0
  end
end
