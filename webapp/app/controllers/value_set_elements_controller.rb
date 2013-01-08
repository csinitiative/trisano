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

class ValueSetElementsController <  AdminController

  def index
    @value_set_elements = ValueSetElement.find(:all)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @value_set_elements }
    end
  end

  def show
    head :method_not_allowed
  end

  def new
    begin
      @value_set_element = ValueSetElement.new
      @value_set_element.parent_element_id = params[:form_element_id]
      @value_set_element.form_id = params[:form_id]

      @reference_element = FormElement.find(params[:form_element_id])
      @library_elements = []
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_value_set_element_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    @value_set_element = ValueSetElement.find(params[:id])
  end

  def create
    @value_set_element = ValueSetElement.new(params[:value_set_element])

    respond_to do |format|
      if @value_set_element.save_and_add_to_form
        format.xml { render :xml => @value_set_element, :status => :created, :location => @value_set_element }
        format.js { @form = Form.find(@value_set_element.form_id)}
      else
        @value_set_element = post_transaction_refresh(@value_set_element, params[:value_set_element])
        @reference_element = FormElement.find(@value_set_element.parent_element_id)
        @library_elements = []
        format.xml  { render :xml => @value_set_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  def update

    @value_set_element = ValueSetElement.find(params[:id])

    respond_to do |format|
      if @value_set_element.update_and_validate(params[:value_set_element])
        format.html { redirect_to(@value_set_element) }
        format.xml  { head :ok }
        format.js { @form = Form.find(@value_set_element.form_id)}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @value_set_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "edit" }
      end
    end
  end

  def destroy
    @value_set_element = ValueSetElement.find(params[:id])
    @value_set_element.destroy_and_validate

    respond_to do |format|
      format.html { redirect_to(value_set_elements_url) }
      format.xml  { head :ok }
    end
  end

  # Debt: Maybe this should move to a value_controller. Putting here for expediency.
  def toggle_value
    begin
      @value_element = ValueElement.find(params[:value_element_id])
      @value_element.toggle(:is_active)
      @value_element.save!
      @form = Form.find(@value_element.form_id)
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_toggle_value")
      render :template => 'rjs-error'
    end
  end

end
