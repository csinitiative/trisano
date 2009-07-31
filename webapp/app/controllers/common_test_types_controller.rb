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

class CommonTestTypesController < ApplicationController

  before_filter :deny_access_unless_admin_user

  def index
    @common_test_types = CommonTestType.find(:all, :order => 'common_name')
  end

  def new
    @common_test_type = CommonTestType.new
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

  def show
    @common_test_type = CommonTestType.find(params[:id])
  end

end
