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

class ExportColumnsController < AdminController

  def index
    @export_columns = ExportColumn.find(:all, :include => 'export_name', :conditions => "export_names.export_name = 'CDC'", :order => "export_columns.name ASC")
  end

  def show
    @export_column = ExportColumn.find(params[:id])
  end

  def new
    @export_column = ExportColumn.new
  end

  def edit
    @export_column = ExportColumn.find(params[:id])
  end

  def create
    @export_column = ExportColumn.new(params[:export_column])
    @export_column.export_name = ExportName.find(:first, :conditions => "export_name = 'CDC'") 

    respond_to do |format|
      if @export_column.save
        flash[:notice] = 'Export Column was successfully created.'
        format.html { redirect_to(@export_column) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @export_column = ExportColumn.find(params[:id])
    
    respond_to do |format|
      if @export_column.update_attributes(params[:export_column])
        flash[:notice] = 'Export Column was successfully updated.'
        format.html { redirect_to(@export_column) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @export_column = ExportColumn.find(params[:id])
    @export_column.destroy

    respond_to do |format|
      format.html { redirect_to(export_columns_url) }
    end
  end

end
