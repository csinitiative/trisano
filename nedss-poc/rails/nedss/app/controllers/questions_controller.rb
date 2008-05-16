class QuestionsController < ApplicationController
  # GET /questions
  # GET /questions.xml
  def index
    @questions = Question.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # Just used through RJS
  def new
    begin
      @question = Question.new
      @question.parent_element_id = params[:form_element_id]
      @question.core_data = params[:core_data]
    rescue Exception => ex
      logger.info ex
      flash[:notice] = 'Unable to display the new question form.'
      render :template => 'rjs-error'
    end
    
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new(params[:question])
    
    respond_to do |format|
      if @question.save_and_add_to_form(params[:question][:parent_element_id])
        form_id = @question.is_core_data ? @question.core_data_element.form_id : @question.question_element.form_id
        flash[:notice] = 'Question was successfully created.'
        format.html { redirect_to(@question) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
        format.js { @form = Form.find(form_id)}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = 'Question was successfully updated.'
        format.html { redirect_to(@question) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end
end
