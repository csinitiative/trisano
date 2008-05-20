class SectionElementsController < ApplicationController
  # GET /section_elements
  # GET /section_elements.xml
  def index
    @section_elements = SectionElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @section_elements }
    end
  end

  # GET /section_elements/1
  # GET /section_elements/1.xml
  def show
    @section_elements = SectionElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section_elements }
    end
  end

  # Just used through RJS
  def new
    begin
      @section_element = SectionElement.new
      @section_element.parent_element_id = params[:form_element_id]
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the section form  at this time.'
      render :template => 'rjs-error'
    end
  end

  # GET /section_elements/1/edit
  def edit
    @section_element = SectionElement.find(params[:id])
  end
  
  def create
    @section_element = SectionElement.new(params[:section_element])

    respond_to do |format|
      if @section_element.save_and_add_to_form
        flash[:notice] = 'Section configuration was successfully created.'
        format.xml  { render :xml => @section_element, :status => :created, :location => @section_element }
        format.js { @form = Form.find(@section_element.form_id)}
      else
        format.xml  { render :xml => @section_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  # PUT /section_elements/1
  # PUT /section_elements/1.xml
  def update
    @section_element = SectionElement.find(params[:id])

    respond_to do |format|
      if @section_element.update_attributes(params[:section_element])
        flash[:notice] = 'Section was successfully updated.'
        format.html { redirect_to(@section_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @section_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /section_elements/1
  # DELETE /section_elements/1.xml
  def destroy
    @section_element = SectionElement.find(params[:id])
    @section_element.destroy

    respond_to do |format|
      format.html { redirect_to(section_elements_url) }
      format.xml  { head :ok }
    end
  end
end
