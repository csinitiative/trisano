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

class LoincCodesController < AdminController
  before_filter :check_role
  before_filter :find_loinc, :only => [:edit, :update, :show, :destroy]

  def index
    @loinc_codes = LoincCode.paginate :page => params[:page]
  end

  def new
    @loinc_code  = LoincCode.new
  end

  def create
    @loinc_code = LoincCode.new(params[:loinc_code])

    respond_to do |format|
      if @loinc_code.save
        redis.delete_matched("views/events/*")

        flash[:notice] = t("loinc_code_created")
        format.html { redirect_to(@loinc_code) }
      else
        format.html { render :action => "new", :status => :bad_request }
      end
    end
  end

  def update
    if params[:loinc_code]
      params[:loinc_code][:disease_ids] ||= []
    end
    respond_to do |format|
      if @loinc_code.update_attributes(params[:loinc_code])
        redis.delete_matched("views/events/*")

        flash[:notice] = t("loinc_code_updated")
        format.html { redirect_to @loinc_code }
      else
        format.html { render :action => :edit, :status => :bad_request }
      end
    end
  end

  def destroy
    respond_to do |format|
      @loinc_code.destroy
      redis.delete_matched("views/events/*")
      flash[:notice] = t("loinc_code_deleted")
      format.html { redirect_to loinc_codes_path }
    end
  end

  def edit
  end

  def show
  end

  private

  def find_loinc
    @loinc_code = LoincCode.find(params[:id])
  end
end
