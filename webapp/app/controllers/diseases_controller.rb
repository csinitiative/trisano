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

class DiseasesController < AdminController

  def index
    @diseases = Disease.find(:all, :order => "disease_name ASC")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @diseases }
      format.json { render :json => @diseases }
    end
  end

  def show
    @disease = Disease.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @disease }
    end
  end

  def new
    @disease = Disease.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @disease }
    end
  end

  def edit
    @disease = Disease.find(params[:id])
  end

  def create
    @disease = Disease.new(params[:disease])

    respond_to do |format|
      if @disease.save
        redis.delete_matched("views/events/*")

        flash[:notice] = t("disease_successfully_created")
        format.html { redirect_to(@disease) }
        format.xml  { render :xml => @disease, :status => :created, :location => @disease }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @disease.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @disease = Disease.find params[:id]

    if params[:disease]
      params[:disease][:cdc_disease_export_status_ids] ||= []
      params[:disease][:avr_group_ids] ||= []
    end

    respond_to do |format|
      if @disease.update_attributes params[:disease]
        redis.delete_matched("views/events/*")

        flash[:notice] = t("disease_successfully_updated")
        format.html { redirect_to(@disease) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @disease = Disease.find(params[:id])
    @disease.destroy

    redis.delete_matched("views/events/*")

    respond_to do |format|
      format.html { redirect_to(diseases_url) }
      format.xml  { head :ok }
    end
  end

end
