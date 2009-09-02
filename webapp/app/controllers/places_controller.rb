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

class PlacesController < AdminController

  before_filter :check_role

  def index
    unless params[:name].nil?
      @place_entities = PlaceEntity.find_for_entity_managment(params)
    end
  end

  def edit
    @place_entity = PlaceEntity.find(params[:id])
    @place_entity.build_canonical_address if @place_entity.canonical_address.nil?
  end

  def update
    @place_entity = PlaceEntity.find(params[:id])

    if @place_entity.update_attributes(params[:place_entity])
      flash[:notice] = 'Place was successfully updated.'
      redirect_to(place_url(@place_entity))
    else
      @place_entity.build_canonical_address if @place_entity.canonical_address.nil?
      render :action => "edit"
    end
  end

  def show
    @place_entity = PlaceEntity.find(params[:id])
  end

  def new
    @place_entity = PlaceEntity.new
    @place_entity.place = Place.new
    @place_entity.canonical_address = Address.new
  end

  def create
    @place_entity = PlaceEntity.new
    @place_entity.place = Place.new
    @place_entity.update_attributes(params[:place_entity])
    
    if @place_entity.save
      flash[:notice] = 'Place was successfully created.'
      redirect_to(place_url(@place_entity))
    else
      @place_entity.canonical_address = Address.new
      render :action => "new"
    end
  end

end
