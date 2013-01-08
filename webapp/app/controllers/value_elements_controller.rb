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

class ValueElementsController <  AdminController

  def index
    head :method_not_allowed
  end

  def show
    head :method_not_allowed
  end

  def new
    begin
      @value_element = ValueElement.new
      @value_element.parent_element_id = params[:form_element_id]
    rescue Exception => ex
      logger.debug ex
      flash[:error] = t("unable_to_display_value_element_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    @value_element = ValueElement.find(params[:id])
    @value_element.parent_element_id = @value_element.parent_id
  end

  def create
    @value_element = ValueElement.new(params[:value_element])

    respond_to do |format|
      if @value_element.save_and_add_to_form
        format.xml  { render :xml => @value_element, :status => :created, :location => @value_element }
        format.js { @form = Form.find(@value_element.form_id)}
      else
        format.xml  { render :xml => @value_element.errors, :status => :unprocessable_entity }
        format.js do
          @value_element = post_transaction_refresh(@value_element, params[:value_element])
          render :action => "new"
        end
      end
    end
  end

  def update
    @value_element = ValueElement.find(params[:id])

    if @value_element.update_and_validate(params[:value_element])
      flash[:notice] = t("value_successfully_updated")
      @form = Form.find(@value_element.form_id)
    else
      @value_element.parent_element_id = @value_element.parent_id
      render :action => "edit"
    end
  end

  def destroy
    head :method_not_allowed
  end

end
