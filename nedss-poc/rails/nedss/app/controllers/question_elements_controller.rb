class QuestionElementsController < ApplicationController

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
      
      @reference_element = FormElement.find(params[:form_element_id])
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    rescue Exception => ex
      p ex
      logger.info ex
      flash[:notice] = 'Unable to display the new question form.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @question_element = QuestionElement.find(params[:id])
  end

  def create
    @question_element = QuestionElement.new(params[:question_element])

    if @question_element.save_and_add_to_form
      form_id = @question_element.form_id
      @form = Form.find(form_id)
    else
      render :action => "new" 
    end

  end

  def update
    @question_element = QuestionElement.find(params[:id])

    if @question_element.update_attributes(params[:question_element])
      flash[:notice] = 'Question was successfully updated.'
      @form = Form.find(@question_element.form_id)
    else
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
      @event = params[:event_id].blank? ? Event.new : Event.find(params[:event_id])
    rescue Exception => ex
      logger.info ex
      flash[:notice] = 'Unable to process conditional logic for follow up questions.'
      @error_message_div = "follow-up-error"
      render :template => 'rjs-error'
    end
    
  end

end
