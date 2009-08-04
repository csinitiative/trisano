# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
      format.html # index.html.erb
      format.xml  { render :xml => @diseases }
    end
  end

  def show
    @disease = Disease.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @disease }
    end
  end

  def new
    @disease = Disease.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @disease }
    end
  end

  def edit
    @disease = Disease.find(params[:id])
    @common_test_types = CommonTestType.all(:order => 'common_name ASC')
  end

  def create
    @disease = Disease.new(params[:disease])

    respond_to do |format|
      if @disease.save
        flash[:notice] = 'Disease was successfully created.'
        format.html { redirect_to(@disease) }
        format.xml  { render :xml => @disease, :status => :created, :location => @disease }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @disease.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @disease = Disease.find(params[:id], :include => [:disease_common_test_types])
    unless params[:disease].nil?
      params[:disease][:external_code_ids] ||= []
      common_test_type_ids = params[:disease].delete(:common_test_type_ids){[]}.collect(&:to_i)
    end

    respond_to do |format|
      begin
        Disease.transaction do
          @disease.update_attributes!(params[:disease])
          @disease.update_common_test_types(common_test_type_ids)
        end
        flash[:notice] = 'Disease was successfully updated.'
        format.html { redirect_to(@disease) }
      rescue
        @common_test_types = CommonTestType.all(:order => 'common_name ASC')
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @disease = Disease.find(params[:id])
    @disease.destroy

    respond_to do |format|
      format.html { redirect_to(diseases_url) }
      format.xml  { head :ok }
    end
  end

end
