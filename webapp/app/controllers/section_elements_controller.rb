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

class SectionElementsController <  AdminController

  def index
    @section_elements = SectionElement.find(:all)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @section_elements }
    end
  end

  def show
    @section_elements = SectionElement.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @section_elements }
    end
  end

  def new
    begin
      @section_element = SectionElement.new
      @section_element.parent_element_id = params[:form_element_id]
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_section_element_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    @section_element = SectionElement.find(params[:id])
  end
  
  def create
    @section_element = SectionElement.new(params[:section_element])

    respond_to do |format|
      if @section_element.save_and_add_to_form
        format.xml  { render :xml => @section_element, :status => :created, :location => @section_element }
        format.js { @form = Form.find(@section_element.form_id)}
      else
        format.xml  { render :xml => @section_element.errors, :status => :unprocessable_entity }
        format.js do
          @section_element = post_transaction_refresh(@section_element, params[:section_element])
          render :action => "new" 
        end
      end
    end
  end

  def update
    @section_element = SectionElement.find(params[:id])

    if @section_element.update_and_validate(params[:section_element])
      flash[:notice] = t("section_updated")
      @form = Form.find(@section_element.form_id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @section_element = SectionElement.find(params[:id])
    @section_element.destroy_and_validate

    respond_to do |format|
      format.html { redirect_to(section_elements_url) }
      format.xml  { head :ok }
    end
  end
end
