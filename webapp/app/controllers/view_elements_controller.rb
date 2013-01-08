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

class ViewElementsController < AdminController

  def index
    respond_to do |format|
      format.html { head :not_found }
    end
  end

  def show
    respond_to do |format|
      format.html { head :not_found }
    end
  end

  def new
    begin
      @view_element = ViewElement.new
      @view_element.parent_element_id = params[:form_element_id]
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_view_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    head :not_found
  end

  def create
    @view_element = ViewElement.new(params[:view_element])

    respond_to do |format|
     if @view_element.save_and_add_to_form
        format.xml  { render :xml => @view_element, :status => :created, :location => @view_element }
        format.js { @form = Form.find(@view_element.form_id)}
      else
        @view_element = post_transaction_refresh(@view_element, params[:view_element])
        flash[:error] = t("unable_to_create_new_tab")
        format.xml  { render :xml => @view_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  def update
    head :not_found
  end

  def destroy
    @view_element = ViewElement.find(params[:id])
    @view_element.destroy_and_validate

    respond_to do |format|
      format.html { redirect_to(view_elements_url) }
      format.xml  { head :ok }
    end
  end
end
