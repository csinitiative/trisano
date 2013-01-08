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

class GroupElementsController <  AdminController

  def index
    @group_elements = GroupElement.find(:all)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @group_elements }
    end
  end

  def show
    @group_elements = GroupElement.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @group_elements }
    end
  end

  def new
    begin
      @group_element = GroupElement.new
      @reference_element = FormElement.find(params[:form_element_id]) 
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_group_element_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    @group_element = GroupElement.find(params[:id])
  end
  
  def create
    @group_element = GroupElement.new(params[:group_element])
    @reference_element = FormElement.find(params[:reference_element_id])      

    if @group_element.save_and_add_to_form
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    else
      flash[:error] = t("unable_to_create_group")
      @group_element = post_transaction_refresh(@group_element, params[:group_element])
      render :template => 'rjs-error'
    end
  end

  def update
    @group_element = GroupElement.find(params[:id])

    respond_to do |format|
      if @group_element.update_attributes(params[:group_element])
        flash[:notice] = t("group_updated")
        format.html { redirect_to(@group_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group_element = GroupElement.find(params[:id])
    @group_element.destroy

    respond_to do |format|
      format.html { redirect_to(group_elements_url) }
      format.xml  { head :ok }
    end
  end
end
