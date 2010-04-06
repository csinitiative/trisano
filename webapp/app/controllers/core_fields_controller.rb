# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class CoreFieldsController < ApplicationController

  def index
    @core_fields = CoreField.find(:all, :order => 'event_type')
    @core_fields = @core_fields.sort_by(&:name)
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @core_fields }
    end
  end

  def show
    @core_field = CoreField.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @core_field }
    end
  end
  
  def edit
    @core_field = CoreField.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end

  def update
    @core_field = CoreField.find(params[:id])

    respond_to do |format|
      if @core_field.update_attributes(params[:core_field])
        flash[:notice] = t("core_field_successfully_updated")
        format.html { redirect_to(@core_field) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @core_field.errors, :status => :unprocessable_entity }
      end
    end
  end
end
