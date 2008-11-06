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

class QuestionElementsController <  AdminController

  skip_before_filter :check_role, :only => :process_condition

  def index
    @question_elements = QuestionElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @question_elements }
    end
  end

  def show
    @question_element = QuestionElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question_element }
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
      flash[:error] = 'Unable to display the new question form.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @question_element = QuestionElement.find(params[:id], :include => :form)
    @export_columns = export_columns(@question_element.form.disease_ids)
  end

  def create
    @question_element = QuestionElement.new(params[:question_element])

    if @question_element.save_and_add_to_form
      form_id = @question_element.form_id
      @form = Form.find(form_id)
    else
      @question_element = post_transaction_refresh(@question_element, params[:question_element])
      @question_element.question = Question.new(params[:question_element][:question_attributes])
      @reference_element = FormElement.find(@question_element.parent_element_id)
      @library_elements = []
      @export_columns = export_columns(@reference_element.form.disease_ids)
      render :action => "new" 
    end

  end

  def update
    @question_element = QuestionElement.find(params[:id])

    if @question_element.update_attributes(params[:question_element])
      flash[:notice] = 'Question was successfully updated.'
      @form = Form.find(@question_element.form_id)
    else
      @export_columns = export_columns(@question_element.form.disease_ids)
      render :action => "edit"
    end

  end

  def destroy
    render :text => 'Deletion handled by form elements.', :status => 405
  end
    
  def process_condition
    begin
      @question_element_id = params[:question_element_id]
      @follow_up = QuestionElement.find(@question_element_id).process_condition(params, params[:event_id])
      @event = Event.find(params[:event_id])
    rescue Exception => ex
      logger.info ex
      flash[:error] = 'Unable to process conditional logic for follow up questions.'
      @error_message_div = "follow-up-error"
      render :template => 'rjs-error'
    end
    
  end
  
  private
  
  def export_columns(disease_ids)
    ExportColumn.find(
      :all,
      :conditions => [" diseases_export_columns.disease_id IN (?)", disease_ids],
      :joins => "LEFT JOIN diseases_export_columns ON diseases_export_columns.export_column_id = export_columns.id",
      :order => "name DESC"
    )
  end

end
