class ValueSetElementsController < ApplicationController
  # GET /value_set_elements
  # GET /value_set_elements.xml
  def index
    @value_set_elements = ValueSetElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @value_set_elements }
    end
  end

  # GET /value_set_elements/1
  # GET /value_set_elements/1.xml
  def show
    @value_set_element = ValueSetElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @value_set_element }
    end
  end

  # GET /value_set_elements/new
  # GET /value_set_elements/new.xml
  def new
    @value_set_element = ValueSetElement.new
    @value_set_element.parent_element_id = params[:form_element_id]
    @value_set_element.form_id = params[:form_id]
  end

  # GET /value_set_elements/1/edit
  def edit
    @value_set_element = ValueSetElement.find(params[:id])
  end

  # POST /value_set_elements
  # POST /value_set_elements.xml
  def create
    @value_set_element = ValueSetElement.new(params[:value_set_element])

    respond_to do |format|
      if @value_set_element.save_and_add_to_form(params[:value_set_element][:parent_element_id])
        flash[:notice] = 'Value Set was successfully created.'
        format.html { redirect_to(@value_set_element) }
        format.xml  { render :xml => @value_set_element, :status => :created, :location => @value_set_element }
        format.js { @form = Form.find(@value_set_element.form_id)}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @value_set_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  # PUT /value_set_elements/1
  # PUT /value_set_elements/1.xml
  def update
    @value_set_element = ValueSetElement.find(params[:id])

    respond_to do |format|
      if @value_set_element.update_attributes(params[:value_set_element])
        flash[:notice] = 'ValueSetElement was successfully updated.'
        format.html { redirect_to(@value_set_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @value_set_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /value_set_elements/1
  # DELETE /value_set_elements/1.xml
  def destroy
    @value_set_element = ValueSetElement.find(params[:id])
    @value_set_element.destroy

    respond_to do |format|
      format.html { redirect_to(value_set_elements_url) }
      format.xml  { head :ok }
    end
  end
end
