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

class FollowUpElementsController <  AdminController

  def auto_complete_for_core_follow_up_conditions
    condition = params[:follow_up_element][:condition]
    @items = ExternalCode.find_codes_for_autocomplete(condition, 5)
    render :inline => '<ul><% for item in @items %><li id="external_code_id_<%= item.id %>" class="fb-core-code-item">Code: <%= h item.code_description %> (<%= h item.code_name %>)</li><% end %></ul>'
  end
  
  def index
    render :text => 'Method not supported.', :status => 405
  end

  def show
    render :text => 'Method not supported.', :status => 405
  end
  
  def new
    begin
      @follow_up_element = FollowUpElement.new
      @follow_up_element.parent_element_id = params[:form_element_id]
      @follow_up_element.core_data = params[:core_data]
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the follow up form at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @follow_up_element = FollowUpElement.find(params[:id])
  end
  
  def create
    @follow_up_element = FollowUpElement.new(params[:follow_up_element])

    respond_to do |format|
      if @follow_up_element.save_and_add_to_form
        format.xml  { render :xml => @follow_up_element, :status => :created, :location => @follow_up_element }
        format.js { @form = Form.find(@follow_up_element.form_id)}
      else
        format.xml  { render :xml => @follow_up_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end


  def update
    render :text => 'Method not supported.', :status => 405
  end

  def destroy
    render :text => 'Deletion handled by form elements.', :status => 405
  end
  
  def process_core_condition
    begin
      @follow_ups = FollowUpElement.process_core_condition(params)
      @event = params[:event_id].blank? ? MorbidityEvent.new : MorbidityEvent.find(params[:event_id])
    rescue Exception => ex
      logger.info ex
      flash[:notice] = 'Unable to process conditional logic for follow up questions.'
      @error_message_div = "follow-up-error"
      render :template => 'rjs-error'
    end
  end
  
end
