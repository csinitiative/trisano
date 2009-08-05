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

class LoincCodesController < AdminController
  before_filter :check_role

  def index
    @loinc_codes = LoincCode.paginate :page => params[:page], :order => 'loinc_code ASC'
  end

  def new
    @loinc_code  = LoincCode.new
  end

  def create
    @loinc_code = LoincCode.new(params[:loinc_code])

    respond_to do |format|
      if @loinc_code.save
        flash[:notice] = 'LOINC code was successfully created.'
        format.html { redirect_to(@loinc_code) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def show
    @loinc_code = LoincCode.find(params[:id])
  end
end
