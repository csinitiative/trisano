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
class CsvFieldsController < ApplicationController
  def index
    @morbidity_event_fields = CsvField.morbidity_event_fields
    @assessment_event_fields = CsvField.assessment_event_fields
    @place_event_fields     = CsvField.place_event_fields
    @contact_event_fields   = CsvField.contact_event_fields
    @lab_fields             = CsvField.lab_fields
    @treatment_fields       = CsvField.treatment_fields
  end

  def set_csv_field_short_name
    @csv_field = CsvField.find(params[:id])
    @csv_field.short_name = params[:value]
    if @csv_field.save
      render :text => @csv_field.short_name
    else
      render :text => @csv_field.errors.full_messages.join("\n"), :status => 500
    end
  end
end
