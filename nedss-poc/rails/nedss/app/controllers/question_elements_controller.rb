class QuestionElementsController < ApplicationController
  # GET /question_elements
  # GET /question_elements.xml
  def index
    @question_elements = QuestionElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @question_elements }
    end
  end

  # GET /question_elements/1
  # GET /question_elements/1.xml
  def show
    @question_element = QuestionElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question_element }
    end
  end

  # Just used through RJS
  def new
    begin
      @question_element = QuestionElement.new
      @question_element.question = Question.new
      @question_element.parent_element_id = params[:form_element_id]
      @question_element.question.core_data = params[:core_data] == "true" ? true : false
      
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    rescue Exception => ex
      logger.info ex
      flash[:notice] = 'Unable to display the new question form.'
      render :template => 'rjs-error'
    end
    
  end

  # GET /question_elements/1/edit
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

end
