# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
    # Keep the li markup below all on the same line, otherwise, a bunch of spaces will be added to the
    # form field when the user selects a code.
    render(:inline => <<-HTML)
       <ul>
         <% for item in @items %>
           <li id="external_code_id_<%= item.id %>" class="fb-core-code-item">Code: <%= h item.code_description %> (<%= h item.code_group.try(:description) %>)</li>
         <% end %>
       </ul>
     HTML
  end

  def index
    render :text => t("method_not_supported"), :status => 405
  end

  def show
    render :text => t("method_not_supported"), :status => 405
  end

  def new
    begin
      @follow_up_element = FollowUpElement.new
      @follow_up_element.parent_element_id = params[:form_element_id]
      @follow_up_element.core_data = params[:core_data]
      @follow_up_element.event_type = params[:event_type]
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_follow_up_element_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    @follow_up_element = FollowUpElement.find(params[:id])

    if @follow_up_element.is_condition_code
      condition_string = FollowUpElement.condition_string_from_code(@follow_up_element.condition)
      @follow_up_element.condition = condition_string.nil? ? @follow_up_element.condition : condition_string
    end

    @follow_up_element.core_data = params[:core_data]
    @follow_up_element.event_type = params[:event_type]
  end

  def create
    @follow_up_element = FollowUpElement.new(params[:follow_up_element])

    respond_to do |format|
      if @follow_up_element.save_and_add_to_form
        format.xml  { render :xml => @follow_up_element, :status => :created, :location => @follow_up_element }
        format.js { @form = Form.find(@follow_up_element.form_id)}
      else
        format.xml  { render :xml => @follow_up_element.errors, :status => :unprocessable_entity }
        format.js do
          @follow_up_element = post_transaction_refresh(@follow_up_element, params[:follow_up_element])
          render :action => "new"
        end
      end
    end
  end


  def update
    @follow_up_element = FollowUpElement.find(params[:id])

    if (params[:follow_up_element][:core_data].blank?)
      update = @follow_up_element.update_and_validate(params[:follow_up_element])
    else
      update = @follow_up_element.update_core_follow_up(params[:follow_up_element])
    end

    if update
      flash[:notice] = t("follow_up_element_updated")
      @form = Form.find(@follow_up_element.form_id)
    else
      render :action => "edit"
    end

  end

  def destroy
    render :text => t("deletion_handled_by_form_elements"), :status => 405
  end

  def process_core_condition
    begin
      @follow_ups = FollowUpElement.process_core_condition(params, { :delete_irrelevant_answers => true })
      @event = Event.find(params[:event_id])
    rescue Exception => ex
      logger.info ex
      flash[:notice] = t("unable_to_process_follow_up_conditional")
      @error_message_div = "follow-up-error"
      render :template => 'rjs-error'
    end
  end

end
