# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
class AvrGroupsController < AdminController

  def index
    @avr_groups = AvrGroup.all(:order => "name ASC")
  end

  def show
    @avr_group = AvrGroup.find(params[:id])
  end

  def new
    @avr_group = AvrGroup.new
  end

  def edit
    @avr_group = AvrGroup.find(params[:id])
  end

  def create
    @avr_group = AvrGroup.new(params[:avr_group])

    if @avr_group.save
      flash[:notice] = t("avr_group_successfully_created")
      redirect_to(@avr_group)
    else
      render :action => "new"
    end
  end
  
  def update
    @avr_group = AvrGroup.find(params[:id])

    if @avr_group.update_attributes(params[:avr_group])
      flash[:notice] = t("avr_group_successfully_updated")
      redirect_to(@avr_group)
    else
      render :action => "edit"
    end
  end

  def destroy
    @avr_group = AvrGroup.find(params[:id])
    @avr_group.destroy
    redirect_to(avr_groups_url)
  end

end