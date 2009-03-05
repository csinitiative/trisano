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

class EncounterEventsController < EventsController

  def index
    render :text => "Encounters can only be listed from the morbidity event show page of cases that have encounters.", :status => 405
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end

  def new
    render :text => "Encounters can only be created from within a morbidity event.", :status => 405
  end

  def edit
  end

  def create
    render :text => "Encounters can only be created from within a morbidity event.", :status => 405
  end

  def update
  end

  def destroy
    head :method_not_allowed
  end

end
