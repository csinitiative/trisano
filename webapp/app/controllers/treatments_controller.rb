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

class TreatmentsController < AdminController

  before_filter :load_treatments, :only => [:index, :merge]
  def index

  end

  def new
    @treatment = Treatment.new
  end

  def create
    @treatment = Treatment.new(params[:treatment])

    respond_to do |format|
      if @treatment.save
        flash[:notice] = t("treatment_created")
        format.html { redirect_to(@treatment) }
        format.xml  { render :xml => @treatment, :status => :created, :location => @treatment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @treatment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @treatment = Treatment.find(params[:id])
  end

  def update
    @treatment = Treatment.find(params[:id])

    respond_to do |format|
      if @treatment.update_attributes(params[:treatment])
        flash[:notice] = t("treatment_updated")
        format.html { redirect_to(@treatment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @treatment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @treatment = Treatment.find(params[:id])
  end

  def merge
    @treatment = Treatment.find(params[:id])
    render :action => "index"
  end

  private

  def load_treatments
    options = { :order => 'treatment_name ASC' }

    unless params[:treatment_name].blank?
      options.merge!(:conditions => ["treatment_name ILIKE ?", "%#{params[:treatment_name]}%"])
    end

    @treatments = Treatment.all(options)
  end

end
