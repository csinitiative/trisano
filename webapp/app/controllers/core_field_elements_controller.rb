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

class CoreFieldElementsController < ApplicationController
    
  def index
    head :method_not_allowed
  end

  def show
    head :method_not_allowed
  end
  
  def new
    begin
      @core_field_element = CoreFieldElement.new(:parent_element_id => params[:form_element_id])
      @available_core_fields = @core_field_element.available_core_fields
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_core_field_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    head :method_not_allowed
  end

  def create
    @core_field_element = CoreFieldElement.new(params[:core_field_element])
    
    respond_to do |format|
      if @core_field_element.save_and_add_to_form
        flash[:notice] = t("core_field_configuration_successfully_created")
        format.xml  { render :xml => @core_field_element, :status => :created, :location => @core_field_element }
        format.js { @form = Form.find(@core_field_element.form_id)}
      else
        format.xml  { render :xml => @core_field_element.errors, :status => :unprocessable_entity }
        format.js { 
          @core_field_element = post_transaction_refresh(@core_field_element, params[:core_field_element])
          @available_core_fields = @core_field_element.available_core_fields
          render :action => "new"
        }
      end
    end
  end
  
  def update
    head :method_not_allowed
  end

  def destroy
    @core_field_element = CoreFieldElement.find(params[:id])
    @core_field_element.destroy_and_validate

    respond_to do |format|
      format.html { redirect_to(core_field_elements_url) }
      format.xml  { head :ok }
    end
  end
end
