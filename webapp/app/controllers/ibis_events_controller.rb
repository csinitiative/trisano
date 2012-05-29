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

class IbisEventsController < AdminController

  def index
  end

  def by_range
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue
      flash[:error] = t("invalid_ibis_date_format")
      redirect_to ibis_events_path
      return
    end
    @events_to_export = IbisExport.exportable_ibis_records(start_date, end_date)
    IbisExport.reset_ibis_status(@events_to_export)
    headers['Content-Disposition'] = "Attachment; filename=\"ibis.xml\""
    render :template => "ibis_events/ibis", :layout => false
  end

  def show
    head :method_not_allowed
  end
  
  def new
    head :method_not_allowed
  end

  def edit
    head :method_not_allowed
  end

  def create
    head :method_not_allowed
  end

  def update
    head :method_not_allowed
  end

  def delete
    head :method_not_allowed
  end

end
