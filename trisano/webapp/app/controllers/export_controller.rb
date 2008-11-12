# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
class ExportController < ApplicationController
  
  def cdc
    @events = []
    @events << CdcExport.verification_records
    @events << CdcExport.weekly_cdc_export
    @events << CdcExport.weekly_cdc_deletes
    @events.flatten!
    CdcExport.reset_sent_status(@events)
    respond_to do |format|
      format.dat
    end
  end

  def ibis
    event_ids_to_export = Event.exportable_ibis_records
    @events_to_export = Event.find(event_ids_to_export.map { |event| event.event_id })
    Event.reset_ibis_status(event_ids_to_export)
  end

end
