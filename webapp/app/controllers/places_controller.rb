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

class PlacesController < ApplicationController

  before_filter :check_permissions
  before_filter :init_search_form, :only => [:index]

  def index
    @place_entities = (params[:name] ? PlaceEntity.by_name_and_participation_type(@search_form) : [])
    respond_to do |format|
      format.html 
      format.xml { render :xml => @place_entities.to_xml(:include => :place) }
    end
  end

  def edit
    @place_entity = PlaceEntity.find(params[:id])
    @place_entity.build_canonical_address if @place_entity.canonical_address.nil?
    @place_entity.telephones << Telephone.new if @place_entity.telephones.empty?
  end

  def update
    redis.delete_matched("views/events/*")

    @place_entity = PlaceEntity.find(params[:id])

    if @place_entity.update_attributes(params[:place_entity])
      flash[:notice] = t("place_updated")
      redirect_to(place_url(@place_entity))
    else
      @place_entity.build_canonical_address if @place_entity.canonical_address.nil?
      @place_entity.telephones << Telephone.new if @place_entity.telephones.empty?
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
    @place_entity.telephones << Telephone.new
  end

  def create
    redis.delete_matched("views/events/*")

    @place_entity = PlaceEntity.new
    @place_entity.place = Place.new
    @place_entity.update_attributes(params[:place_entity])

    if @place_entity.save
      flash[:notice] = t("place_created")
      redirect_to(place_url(@place_entity))
    else
      @place_entity.telephones << Telephone.new
      @place_entity.canonical_address = Address.new
      render :action => "new"
    end
  end

  private

  def init_search_form
    @search_form = PlacesSearchForm.new(params)
  end

  def check_permissions
    unless User.current_user.is_entitled_to?(:manage_entities)
      respond_to do |format|
        format.html do
          render :partial => "places/permission_denied", :locals => { :reason => t("no_place_management_privs") }, :layout => true, :status => 403
        end
        format.xml { head :forbidden }
      end
      return
    end
  end
end
