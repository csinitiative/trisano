class CoreFieldElementsController < ApplicationController
    
  def index
    @core_field_elements = CoreFieldElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @core_field_elements }
    end
  end

  def show
    @core_field_element = CoreFieldElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @core_field_element }
    end
  end
  
  def new
    begin
      @core_field_element = CoreFieldElement.new(:parent_element_id => params[:form_element_id])
      @available_core_fields = @core_field_element.available_core_fields
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the core field form  at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @core_field_element = CoreFieldElement.find(params[:id])
  end

  def create
    @core_field_element = CoreFieldElement.new(params[:core_field_element])
    
    respond_to do |format|
      if @core_field_element.save_and_add_to_form
        flash[:notice] = 'Core field configuration was successfully created.'
        format.xml  { render :xml => @core_field_element, :status => :created, :location => @core_field_element }
        format.js { @form = Form.find(@core_field_element.form_id)}
      else
        format.xml  { render :xml => @core_field_element.errors, :status => :unprocessable_entity }
        format.js { 
          @available_core_fields = @core_field_element.available_core_fields
          render :action => "new"
        }
      end
    end
  end
  
  def update
    @core_field_element = CoreFieldElement.find(params[:id])

    respond_to do |format|
      if @core_field_element.update_attributes(params[:core_field_element])
        flash[:notice] = 'Core Field Element was successfully updated.'
        format.html { redirect_to(@core_field_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @core_field_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @core_field_element = CoreFieldElement.find(params[:id])
    @core_field_element.destroy

    respond_to do |format|
      format.html { redirect_to(core_field_elements_url) }
      format.xml  { head :ok }
    end
  end
end
