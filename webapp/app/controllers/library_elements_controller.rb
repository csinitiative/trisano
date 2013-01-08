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

class LibraryElementsController < AdminController
    
  def index
    # Nothing to do at the moment
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

  def destroy
    head :method_not_allowed
  end

  def import
    if params[:import].blank?
      flash[:error] = t("navigate_to_library_import_file")
      render :action => 'index'
      return
    end

    begin
      Form.import_library(params[:import])
      flash[:notice] = t("library_import_successful")
      redirect_to library_elements_path
    rescue Exception => ex
      logger.debug ex.backtrace
      flash[:error] = t("library_import_failed", :message => ex.message)
      redirect_to library_elements_path
    end
  end

  def export
    begin
      export_file_path = Form.export_library
      response.headers['Content-type'] = "application/zip"
      send_file export_file_path
      #head :ok    # Makes RSpec happy with rails 2.3, but breaks behavior in browser
      return
    rescue Exception => ex
      logger.debug ex.backtrace
      error_message = t("library_export_failed", :message => ex.message)
      flash[:error] = error_message
      redirect_to library_elements_path
    end
  end
  
end
