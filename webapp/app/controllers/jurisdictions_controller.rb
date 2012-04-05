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

class JurisdictionsController < AdminController
    
  before_filter :check_role
    
  def index
    @jurisdictions = PlaceEntity.jurisdictions.excluding_unassigned
  end

  def show
    @jurisdiction = PlaceEntity.jurisdictions.excluding_unassigned.find(params[:id])
  end

  def new
    @place = Place.new
    @jurisdiction = PlaceEntity.new( :place => @place)
  end

  def edit
    @jurisdiction = PlaceEntity.jurisdictions.excluding_unassigned.find(params[:id])
  end

  def create
    @place = Place.new(params[:jurisdiction][:place_attributes])
    @jurisdiction = PlaceEntity.new(:place => @place)
    @place.place_types = [Code.find(Code.jurisdiction_place_type_id)]

    if @jurisdiction.save
      flash[:notice] = t("jurisdiction_created")
      redirect_to(jurisdiction_url(@jurisdiction))
    else
      render :action => "new"
    end
  end

  def update
    @jurisdiction = PlaceEntity.jurisdictions.excluding_unassigned.find(params[:id])

    if @jurisdiction.update_attributes(params[:jurisdiction])
      flash[:notice] = t("jurisdiction_updated")
      redirect_to(jurisdiction_url(@jurisdiction))
    else
      render :action => "edit"
    end
  end

end
