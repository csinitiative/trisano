class FormElementsController < ApplicationController
  # GET /form_elements
  # GET /form_elements.xml
  def index
    @form_elements = FormElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @form_elements }
    end
  end

  # GET /form_elements/1
  # GET /form_elements/1.xml
  def show
    @form_element = FormElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @form_element }
    end
  end

  # GET /form_elements/new
  # GET /form_elements/new.xml
  def new
    @form_element = FormElement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @form_element }
    end
  end

  # GET /form_elements/1/edit
  def edit
    @form_element = FormElement.find(params[:id])
  end

  # POST /form_elements
  # POST /form_elements.xml
  def create
    @form_element = FormElement.new(params[:form_element])

    respond_to do |format|
      if @form_element.save
        flash[:notice] = 'FormElement was successfully created.'
        format.html { redirect_to(@form_element) }
        format.xml  { render :xml => @form_element, :status => :created, :location => @form_element }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @form_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /form_elements/1
  # PUT /form_elements/1.xml
  def update
    @form_element = FormElement.find(params[:id])

    respond_to do |format|
      if @form_element.update_attributes(params[:form_element])
        flash[:notice] = 'FormElement was successfully updated.'
        format.html { redirect_to(@form_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @form_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      @form_element = FormElement.find(params[:id])
      @form_element.destroy_with_dependencies
      flash[:notice] = 'The form element was successfully deleted.'
      @form = Form.find(@form_element.form_id)
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'An error occurred during the deletion process.'
      render :template => 'rjs-error'
    end
  end
  
  def filter_elements
    if params[:filter_by].blank?
      @library_elements = FormElement.roots(:conditions => ["form_id IS NULL"])
    else
      @library_elements = FormElement.find_by_sql("SELECT * FROM form_elements WHERE form_id IS NULL AND id IN (SELECT question_element_id FROM questions WHERE question_text ILIKE '%#{params[:filter_by]}%')")
    end
    p @library_elements
    render :partial => "forms/library_elements"
  end
end
