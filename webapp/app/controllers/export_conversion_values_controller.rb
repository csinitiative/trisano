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

class ExportConversionValuesController < AdminController

  before_filter :find_export_column

  def index
    redirect_to export_column_url(@export_column)
  end

  def show
    redirect_to export_column_url(@export_column)
  end

  def new
    @export_conversion_value = ExportConversionValue.new
  end

  def edit
    @export_conversion_value = @export_column.export_conversion_values.find(params[:id])
  end

  def create
    @export_conversion_value = ExportConversionValue.new(params[:export_conversion_value])

    if (@export_column.export_conversion_values << @export_conversion_value)
      flash[:notice] = t("export_conversion_value_created")
      redirect_to export_column_url(@export_column)
    else
      render :action => "new"
    end
  end

  def update
    @export_conversion_value = @export_column.export_conversion_values.find(params[:id])
    
    if @export_conversion_value.update_attributes(params[:export_conversion_value])
      flash[:notice] = t("export_conversion_value_updated")
      redirect_to export_column_url(@export_column)
    else
      render :action => "edit"
    end
  end

  def destroy
    export_conversion_value =  @export_column.export_conversion_values.find(params[:id])
    @export_column.export_conversion_values.delete(export_conversion_value)
    redirect_to export_column_url(@export_column)
  end

  private

  def find_export_column
    export_column_id = params[:export_column_id]
    redirect_to export_column_url unless export_column_id
    @export_column = ExportColumn.find(export_column_id)
  end

end
