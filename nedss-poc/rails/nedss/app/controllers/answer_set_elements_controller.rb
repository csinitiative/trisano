class AnswerSetElementsController < ApplicationController
  # GET /answer_set_elements
  # GET /answer_set_elements.xml
  def index
    @answer_set_elements = AnswerSetElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @answer_set_elements }
    end
  end

  # GET /answer_set_elements/1
  # GET /answer_set_elements/1.xml
  def show
    @answer_set_element = AnswerSetElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @answer_set_element }
    end
  end

  # GET /answer_set_elements/new
  # GET /answer_set_elements/new.xml
  def new
    @answer_set_element = AnswerSetElement.new
    @answer_set_element.parent_element_id = params[:form_element_id]
    @answer_set_element.form_id = params[:form_id]
  end

  # GET /answer_set_elements/1/edit
  def edit
    @answer_set_element = AnswerSetElement.find(params[:id])
  end

  # POST /answer_set_elements
  # POST /answer_set_elements.xml
  def create
    @answer_set_element = AnswerSetElement.new(params[:answer_set_element])

    respond_to do |format|
      if @answer_set_element.save_and_add_to_form(params[:answer_set_element][:parent_element_id])
        flash[:notice] = 'Answer Set was successfully created.'
        format.html { redirect_to(@answer_set_element) }
        format.xml  { render :xml => @answer_set_element, :status => :created, :location => @answer_set_element }
        format.js { @form = Form.find(@answer_set_element.form_id)}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @answer_set_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  # PUT /answer_set_elements/1
  # PUT /answer_set_elements/1.xml
  def update
    @answer_set_element = AnswerSetElement.find(params[:id])

    respond_to do |format|
      if @answer_set_element.update_attributes(params[:answer_set_element])
        flash[:notice] = 'AnswerSetElement was successfully updated.'
        format.html { redirect_to(@answer_set_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer_set_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /answer_set_elements/1
  # DELETE /answer_set_elements/1.xml
  def destroy
    @answer_set_element = AnswerSetElement.find(params[:id])
    @answer_set_element.destroy

    respond_to do |format|
      format.html { redirect_to(answer_set_elements_url) }
      format.xml  { head :ok }
    end
  end
end
