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

class CommonTestTypesController < AdminController

  before_filter :check_role

  def index
    @common_test_types = CommonTestType.find(:all, :order => 'common_name')
  end

  def new
    @common_test_type = CommonTestType.new
  end

  def edit
    @common_test_type = CommonTestType.find(params[:id])
  end

  def loinc_codes
    @common_test_type = CommonTestType.find(params[:id])

    if params[:do] == "Search"
      conditions = ["test_name ILIKE ?", "%#{params[:loinc_code_search_test_name]}%"] if params[:loinc_code_search_test_name]
      @loinc_codes = LoincCode.find(:all, :conditions => conditions, :order => 'loinc_code ASC')
    end
  end

  def create
    @common_test_type = CommonTestType.new(params[:common_test_type])

    respond_to do |format|
      if @common_test_type.save
        flash[:notice] = 'Common test type was successfully created.'
        format.html { redirect_to(@common_test_type) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @common_test_type = CommonTestType.find(params[:id])

    respond_to do |format|
      if @common_test_type.update_attributes(params[:common_test_type])
        flash[:notice] = 'Common test type was successfully updated.'
        format.html { redirect_to(@common_test_type) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def update_loincs
    @common_test_type = CommonTestType.find(params[:id])
    new_loincs = params[:added_loinc_codes] || []

    respond_to do |format|
      begin
        LoincCode.update_all("common_test_type_id = #{@common_test_type.id}", ["id IN (?)", new_loincs])
        flash[:notice] = 'Common test type was successfully updated.'
        format.html { redirect_to loinc_codes_common_test_type_path(@common_test_type) }
      rescue
        logger.error($!.message)
        flash.now[:error] = "TriSano could not complete the last request. Contact your system administrator"
        format.html { render :action => :add_loincs, :status => 500 }
      end
    end
  end

  def show
    @common_test_type = CommonTestType.find(params[:id])
  end

end
