# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class CoreFieldsController < AdminController

  before_filter :look_up_disease
  before_filter :inject_disease_into_core_field_hash, :only => [:update]

  def index
    @core_fields = CoreField.roots :order => 'tree_id'

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

        expire_fragment(%r{/events/})

        format.html do
          flash[:notice] = t("core_field_successfully_updated")
          redirect_to [@disease, @core_field]
        end
        format.xml  { head :ok }
        format.js   do
          render(:partial => 'core_field',
                 :locals => { :core_field => @core_field },
                 :layout => false)
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @core_field.errors, :status => :unprocessable_entity }
        format.js   { render :json => @core_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def apply_to
    unless @disease
      head :not_found
      return
    end

    respond_to do |format|
      if @disease.apply_core_fields_to params[:other_disease_ids]
        expire_fragment(%r{/events/})

        flash[:notice] = t(:core_fields_successfully_copied)
        format.html { redirect_to diseases_path }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        logger.error(@disease.errors.full_messages.join("\n"))
        flash[:error] = @disease.errors.full_messages.join("\n")
        format.html { redirect_to disease_core_fields_path(@disease) }
        format.xml  { render :xml => @disease.errors, :status => :unprocessable_entity }
        format.json { render :json => @disease.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def look_up_disease
    unless params[:disease_id].blank?
      @disease = Disease.find(params[:disease_id])
    end
  end

  def inject_disease_into_core_field_hash
    if @disease
      if params[:core_field] && params[:core_field][:rendered_attributes]
        params[:core_field][:rendered_attributes][:disease_id] = @disease.id
      end
    end
  end
end
