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

class CoreViewElementsController <  AdminController

  def index
    @core_view_elements = CoreViewElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @core_view_elements }
    end
  end

  def show
    @core_view_element = CoreViewElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @core_view_element }
    end
  end

  def new
    begin
      @core_view_element = CoreViewElement.new(:parent_element_id => params[:form_element_id])
      @available_core_views = @core_view_element.available_core_views
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the core tab form  at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @core_view_element = CoreViewElement.find(params[:id])
  end
  
  def create
    @core_view_element = CoreViewElement.new(params[:core_view_element])
    
    respond_to do |format|
      if @core_view_element.save_and_add_to_form
        flash[:notice] = 'Core tab configuration was successfully created.'
        format.xml  { render :xml => @core_view_element, :status => :created, :location => @core_view_element }
        format.js { @form = Form.find(@core_view_element.form_id)}
      else
        format.xml  { render :xml => @core_view_element.errors, :status => :unprocessable_entity }
        format.js { 
          @available_core_views = @core_view_element.available_core_views
          render :action => "new"
        }
      end
    end
  end

  def update
    @core_view_element = CoreViewElement.find(params[:id])

    respond_to do |format|
      if @core_view_element.update_attributes(params[:core_view_element])
        flash[:notice] = 'CoreViewElement was successfully updated.'
        format.html { redirect_to(@core_view_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @core_view_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @core_view_element = CoreViewElement.find(params[:id])
    @core_view_element.destroy

    respond_to do |format|
      format.html { redirect_to(core_view_elements_url) }
      format.xml  { head :ok }
    end
  end
end
