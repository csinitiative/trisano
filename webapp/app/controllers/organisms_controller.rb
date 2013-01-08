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
class OrganismsController < AdminController
  before_filter :find_organism, :only => [:edit, :show, :update]

  def index
    @organisms = Organism.all
    respond_to do |format|
      format.html
      format.xml { render :xml => @organisms }
    end
  end

  def show
  end

  def edit
  end

  def new
    @organism = Organism.new
  end

  def create
    @organism = Organism.new(params[:organism])

    respond_to do |format|
      if @organism.save
        redis.delete_matched("views/events/*")

        flash[:notice] = t("organism_created")
        format.html { redirect_to @organism  }
      else
        format.html { render :action => :new, :status => :bad_request }
      end
    end
  end

  def update
    params[:organism][:disease_ids] ||= [] if params[:organism]

    respond_to do |format|
      if @organism.update_attributes params[:organism]
        redis.delete_matched("views/events/*")

        flash[:notice] = t("organism_updated")
        format.html { redirect_to @organism }
      else
        format.html { render :action => :edit, :status => :bad_request }
      end
    end
  end

  private

  def find_organism
    @organism = Organism.find params[:id]
  end
end
