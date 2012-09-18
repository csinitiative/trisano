# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class QuestionElementsController <  AdminController

  skip_before_filter :check_role, :only => :process_condition

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
      @question_element = QuestionElement.new
      @question_element.question = Question.new
      @question_element.parent_element_id = params[:form_element_id]
      @question_element.question.core_data = params[:core_data] == "true" ? true : false

      @reference_element = FormElement.find(params[:form_element_id], :include => :form)
      @library_elements = []
      @export_columns = export_columns(@reference_element.form.disease_ids)
    rescue Exception => ex
      logger.info ex

      flash[:error] = t("unable_to_display_question_element_form")
      render :template => 'rjs-error'
    end
  end

  def edit
    @question_element = QuestionElement.find(params[:id], :include => :form)
  end

  def create
    @question_element = QuestionElement.new(params[:question_element])

    if @question_element.save_and_add_to_form
      form_id = @question_element.form_id
      @form = Form.find(form_id)
    else
      @reference_element = FormElement.find(@question_element.parent_element_id)
      @library_elements = []
      @export_columns = export_columns(@reference_element.form.disease_ids)
      render :action => "new", :status => :bad_request
    end

  end

  def update
    @question_element = QuestionElement.find(params[:id])

    if @question_element.update_and_validate(params[:question_element])
      flash[:notice] = t("question_element_updated")
      @form = Form.find(@question_element.form_id)
    else
      render :action => "edit"
    end

  end

  def destroy
    render :text => t("deletion_handled_by_form_elements"), :status => 405
  end

  def process_condition
    begin
      @form_index = 0
      @question_element_id = params[:question_element_id]
      @processing_event = Event.find(params[:event_id])
      question_element = QuestionElement.find(@question_element_id)
      @follow_ups = question_element.process_condition(
        params,
        params[:event_id],
        :delete_irrelevant_answers => true
      )
      @event = Event.find(params[:event_id])
    rescue Exception => ex
      logger.info ex
      flash[:error] = t("unable_to_process_conditional_logic")
      @error_message_div = "follow-up-error"
      render :template => 'rjs-error'
    end
  end

  private

  def export_columns(disease_ids)
    ExportColumn.find(
      :all,
      :select => "distinct (id), name",
      :conditions => ["diseases_export_columns.disease_id IN (?) AND export_columns.type_data = ?", disease_ids, 'FORM'],
      :joins => "LEFT JOIN diseases_export_columns ON diseases_export_columns.export_column_id = export_columns.id",
      :order => "name"
    )
  end

end
