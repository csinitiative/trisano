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

class FormElementsController <  AdminController

  def index
    head :not_found
  end

  def show
    head :not_found
  end

  def new
    head :not_found
  end

  def edit
    head :not_found
  end

  def create
    head :not_found
  end

  def update
    head :not_found
  end

  def destroy
    @form_element = FormElement.find(params[:id])

    if @form_element.destroy_and_validate

      # A missing form_id means an element in the library is being destroyed, 
      # so the list of elements in the library must be rebuilt for the view (filter
      # conditions are not preserved).
      if (@form_element.form_id.blank?)
        @library_elements = FormElement.library_roots
        @type = params[:type].blank? ? "question_element" : params[:type]
      else
        @form = Form.find(@form_element.form_id)
      end
    else
      @rjs_errors = @form_element.errors
      flash[:error] = t("error_during_delete")
      render :template => 'rjs-error'
    end
  end

  def filter_elements
    @reference_element = FormElement.find(params[:reference_element_id])
    direction = params[:direction]
    @library_elements = FormElement.filter_library(:direction => direction,
                                                   :filter_by => params[:filter_by],
                                                   :type => params[:type].to_sym)
    render :partial => "forms/library_elements",
           :locals => {:direction => direction.to_sym, :type => params[:type].to_sym}
  rescue Exception => ex
    logger.debug ex
    flash[:error] = t("error_during_filtering")
    render :template => 'rjs-error'
  end

  def update_export_column
    @form_element = FormElement.find(params[:id])
    @form_element.export_column_id = params[:export_column_id]
    @form_element.save!
    render(:update) do |page|
      page << "$('cdc-export-info-#{params[:id]}').#{(params[:export_column_id].blank? ? 'hide' : 'show')}();"
    end
  end

end
